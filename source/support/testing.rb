$gtk.disable_console!

def $gtk.quit!
  exit $exit_code
end

Module.new do
  GTK::Tests.prepend(self)

  def start
    super
    $exit_code = 1 if @passed.empty?
    $exit_code = 1 unless @failed.empty?
    $exit_code = 1 unless @inconclusive.empty?
  end
end
