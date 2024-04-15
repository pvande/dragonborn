require "lib/dragonborn"
require "support/testing.rb"

TEST_DIR = File.dirname(__FILE__)

def test_constants_autoload_properly(args, assert)
  already_loaded = $gtk.required_files.count

  Dragonborn.configure { root "#{TEST_DIR}/src" }

  assert.true! Object.const_defined?(:Foo, false), "Foo was not defined"
  assert.true! Object.const_defined?(:Bar, false), "Bar was not defined"
  assert.true! Object.const_defined?(:Baz, false), "Baz was not defined"

  assert.equal! Foo, Bar
  assert.equal! Bar, Baz
  assert.equal! Baz, 123

  assert.equal! $gtk.required_files.drop(already_loaded), %W[
    #{TEST_DIR}/src/baz.rb
    #{TEST_DIR}/src/bar.rb
    #{TEST_DIR}/src/foo.rb
  ]
end
