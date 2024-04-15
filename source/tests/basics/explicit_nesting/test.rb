require "lib/dragonborn"
require "support/testing.rb"

TEST_DIR = File.dirname(__FILE__)

def test_constants_autoload_properly(args, assert)
  already_loaded = $gtk.required_files.count

  Dragonborn.configure { root "#{TEST_DIR}/src" }

  assert.true! Object.const_defined?(:Foo, false), "Foo was not defined"
  assert.true! Foo.const_defined?(:Bar, false), "Foo::Bar was not defined"
  assert.true! Foo::Bar.const_defined?(:Baz, false), "Foo::Bar::Baz was not defined"

  assert.equal! Foo.file, "#{TEST_DIR}/src/foo.rb"
  assert.equal! Foo::Bar.file, "#{TEST_DIR}/src/foo/bar.rb"
  assert.equal! Foo::Bar::Baz.file, "#{TEST_DIR}/src/foo/bar/baz.rb"

  assert.equal! $gtk.required_files.drop(already_loaded), %W[
    #{TEST_DIR}/src/foo.rb
    #{TEST_DIR}/src/foo/bar.rb
    #{TEST_DIR}/src/foo/bar/baz.rb
  ]
end
