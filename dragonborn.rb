module Dragonborn
  class Config
    attr_accessor :ignored, :roots, :debug

    def initialize
      @ignored = ["app/main"]
      @roots = []
      @debug = false
    end

    def ignore(file)
      @ignored << file
      @ignored.uniq!
    end

    def root(dir)
      @roots << dir
    end

    def debug!
      @debug = true
    end

    def inflection(inflection)
      Inflector.customize(inflection)
    end
  end

  class Loader
    LOADABLE_EXTENSIONS = [ "mrb", "rb" ]
    HollowNamespace = Module

    class LoadError < StandardError
      def initialize(file, cpath)
        super "Expected #{file} to define #{cpath}!"
      end
    end

    def self.debug(method_name)
      aliased_method = :"__#{method_name}"
      alias_method aliased_method, method_name

      define_method method_name do |*args|
        next send(aliased_method, *args) unless @debug

        call_args = args.map(&:inspect).join(", ")
        puts_immediate ("  " * @indent) + "#{method_name}(#{call_args})"
        @indent += 1
        send(aliased_method, *args).tap do |result|
          puts_immediate ("  " * (@indent - 1)) + "=> " + result.inspect
          puts_immediate ("  " * (@indent - 1)) + "=> (#{result.object_id})"
        end
      ensure
        @indent -= 1
      end
    end

    def initialize(loadables)
      @loadables = loadables
      @bases = {}
      @root = Object
      @debug = Dragonborn.config.debug
      @indent = 0
    end

    def undefine_all_constants!
      required = [
        :BasicObject,
        # :Kernel,
        # :Hash,
        # :Range,
        # :Integer,
        # :Struct,
        # :String,
        # :NilClass,
        # :IOError,
        # :GC,
        # :Enumerable,
        # :Numeric,
        # :ValueType,
        # :File,
        # :Fixnum,
        # :Time,
        # :Exception,
        # :Array,
        # :Symbol,
        # :ArgumentError,
        # :Enumerator,
        # :StandardError,
        # :NoMethodError,
        # :NameError,
        # :RuntimeError,
        # :NIL,
        # :GTK,
      ]

      (@root.constants - required).each do |cname|
        @bases[cname] = @root.remove_const(cname)
      end
    end

    def restore_constants!
      @bases.each do |cname, const|
        @root.const_set(cname, const)
      end
    end

    debug def find_in_namespace(ns, cname)
      ns == @root ? search_top_level(cname) : search_namespace(ns, cname)
    end

    debug def search_top_level(cname)
      return @bases[cname] if @bases.key?(cname)

      if autoload?("", cname)
        load("", cname)
      elsif namespace?("", cname)
        autovivify("", cname)
      else
        @root.__const_missing(cname)
      end

      @bases[cname] = @root.remove_const(cname)
    end

    debug def search_namespace(ns, cname)
      namespace_parts = ns.name.split("::")
      namespace = ns.name

      until namespace_parts.empty?
        return lookup(namespace, cname) if is_defined?(namespace, cname)
        return load(namespace, cname) if autoload?(namespace, cname)
        return autovivify(namespace, cname) if namespace?(namespace, cname)

        namespace_parts.pop
        namespace = namespace_parts.join("::")
      end

      search_top_level(cname)
    end

    debug def is_defined?(namespace, cname)
      ns = lookup(namespace)
      ns.const_defined?(cname, false)
    end

    debug def autoload?(namespace, cname)
      @loadables.dig(namespace, cname)
    end

    debug def namespace?(namespace, cname)
      # @NOTE `namespace?` is only valid after `autoload?` fails!
      @loadables[namespace]&.key?(cname)
    end

    debug def load(namespace, cname)
      ns = lookup(namespace)
      file = @loadables.dig(namespace, cname)

      if namespace.empty?
        require(file)
      else
        base_cname = namespace.split("::", 2).first
        @root.const_set(base_cname, lookup(base_cname))
        require(file)
        @root.remove_const(base_cname)
      end

      if ns.const_defined?(cname, false)
        ns.const_get(cname)
      else
        path = $gtk.required_files.last
        raise LoadError.new(path, "#{ns == @root ? "" : "#{ns}::"}#{cname}")
      end
    end

    debug def autovivify(namespace, cname)
      ns = lookup(namespace)
      ns.const_set(cname, HollowNamespace.new)
    end

    debug def lookup(cpath)
      return @root if cpath == ""
      unless cpath.include?("::")
        cname = cpath.to_sym
        return @bases[cname] if @bases.key?(cname)
      end

      cpath.split("::").inject(@root) do |ns, cname|
        ns.const_get(cname.to_sym)
      end
    end
  end

  module Inflector
    @customizations = {}
    class << self
      def inflect(name)
        @customizations[name] || begin
          parts = name.split("_").collect! do |part|
            @customizations[part] || part.capitalize! || part
          end

          parts.join.to_sym
        end
      end

      def customize(mappings)
        mappings.transform_values!(&:to_sym)
        @customizations.merge!(mappings)
      end
    end
  end

  @config = Config.new

  class << self
    attr_reader :config

    def require_dir(dir)
      files = $gtk.list_files(dir)
      files.each do |file|
        path = "#{dir}/#{file}"
        next if $gtk.required_files.include?(path)
        stat = $gtk.stat_file(path)
        require path if stat[:file_type] == :regular
      end
    end

    def configure(eager: true, &block)
      @errors = []
      @config.instance_eval(&block)
      reload!
    end

    def reload!
      @config.roots.sort! { |a, b| b.count("/") <=> a.count("/") }
      stats = @config.roots.flat_map { |root| stat_recursively(root) }

      # @TODO Cache require order based on `stats`. Subsequent loads can avoid
      #       the hoop jumping altogether.

      @to_be_loaded = []
      @loadables = stats.group_by { |x| x[:ns] }
      @loadables.transform_values! do |ns_stats|
        actions_by_name = ns_stats.group_by { |x| x[:cname] }
        actions_by_name.transform_values! do |cname_stats|
          if cname_stats.first[:ns].empty? && Object.const_defined?(cname_stats.first[:cpath])
            cname_stats.each do |stat|
              type = stat[:file_type] == :directory ? "directory" : "file"
              @errors << "The #{type} #{stat[:path]} masks #{stat[:cname]}"
            end
          end

          virtual, loadable = cname_stats.partition do |stat|
            stat[:file_type] == :directory
          end

          load_paths = loadable.map { |x| x[:file] }
          load_paths.uniq!

          if load_paths.size == 1
            @to_be_loaded << loadable.first.values_at(:cpath, :file)
            next load_paths.first
          end

          next if loadable.empty? && !virtual.empty?

          cpath = cname_stats.first[:cpath]
          paths = load_paths.map { |path| "  * #{path}" }.join("\n")
          @errors << "Multiple files mapped to #{cpath}\n#{paths}"
          nil
        end
      end

      unless @errors.empty?
        @errors.sort!
        errors = @errors.join("\n").indent(1)
        raise "[Dragonborn] Encountered issues:\n#{errors}"
      end

      finalize!
    end

    private

    def finalize!
      loader = Loader.new(@loadables)
      Module.instance_eval do
        alias_method :__const_missing, :const_missing
        define_method(:const_missing) { |cname| loader.find_in_namespace(self, cname) }
      end

      @to_be_loaded.sort! { |a, b| a.last <=> b.last }

      loader.undefine_all_constants!
      @to_be_loaded.each do |cpath, path|
        next if path == "app/main"
        loader.lookup(cpath)
      end
    ensure
      loader.restore_constants!
      Module.instance_eval do
        alias_method :const_missing, :__const_missing
        remove_method :__const_missing
      end
    end

    def stat_recursively(dir, ns = "")
      $gtk.list_files(dir).sort!.flat_map do |file|
        stat = $gtk.stat_file("#{dir}/#{file}")

        is_dir = stat[:file_type] == :directory
        next [] if is_dir && @config.roots.include?(stat[:path])

        name, _, ext = (is_dir ? [file] : file.rpartition("."))
        next [] unless is_dir || Loader::LOADABLE_EXTENSIONS.include?(ext)

        load_path = "#{dir}/#{name}"
        next [] if @config.ignored.include?(load_path)

        stat[:file] = load_path
        stat[:ext] = ext
        stat[:ns] = ns
        stat[:cname] = Inflector.inflect(name)
        stat[:cpath] = stat.values_at(:ns, :cname).reject(&:empty?).join("::")
        children = stat_recursively(stat[:path], stat[:cpath]) if is_dir

        [ stat, *children ]
      end
    end
  end
end
