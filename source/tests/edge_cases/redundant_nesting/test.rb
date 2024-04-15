require "lib/dragonborn"
require "support/testing.rb"

TEST_DIR = File.dirname(__FILE__)

def test_constants_autoload_properly(args, assert)
  already_loaded = $gtk.required_files.count

  Dragonborn.configure do
    root "#{TEST_DIR}/src"
  end

  depth = 0
  %i[ This Nests Really Really Really Deeply ].reduce(Object) do |ns, cname|
    assert.true! ns.const_defined?(cname, false), "#{ns}::#{cname} was not defined"

    ns.const_get(cname).tap do |const|
      assert.equal! const.depth, (depth += 1)
    end
  end

  assert.equal! $gtk.required_files.drop(already_loaded), %W[
    #{TEST_DIR}/src/this/nests/really/really/really/deeply.rb
  ]
end
