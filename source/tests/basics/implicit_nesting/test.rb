require "lib/dragonborn"
require "support/testing.rb"

TEST_DIR = File.dirname(__FILE__)

def test_constants_autoload_properly(args, assert)
  already_loaded = $gtk.required_files.count

  Dragonborn.configure { root "#{TEST_DIR}/src" }

  assert.true! Object.const_defined?(:Foo, false), "Foo was not defined"
  assert.true! Foo.const_defined?(:Bar, false), "Foo::Bar was not defined"
  assert.true! Foo::Bar.const_defined?(:Baz, false), "Foo::Bar::Baz was not defined"
  assert.true! Foo::Bar.const_defined?(:Qux, false), "Foo::Bar::Qux was not defined"

  assert.true! Foo.is_a?(Module), "Foo had the wrong type"
  assert.true! Foo::Bar.is_a?(Module), "Foo::Bar had the wrong type"
  assert.true! Foo::Bar::Baz.is_a?(Class), "Foo::Bar::Baz had the wrong type"
  assert.true! Foo::Bar::Qux.is_a?(Class), "Foo::Bar::Qux had the wrong type"

  assert.equal! Foo::Bar::Baz.file, "#{TEST_DIR}/src/foo/bar/baz.rb"
  assert.equal! Foo::Bar::Qux.file, "#{TEST_DIR}/src/foo/bar/qux.rb"

  assert.equal! $gtk.required_files.drop(already_loaded), %W[
    #{TEST_DIR}/src/foo/bar/baz.rb
    #{TEST_DIR}/src/foo/bar/qux.rb
  ]
end
