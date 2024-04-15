require "lib/dragonborn"
require "support/testing.rb"

TEST_DIR = File.dirname(__FILE__)

def test_constants_autoload_properly(args, assert)
  already_loaded = $gtk.required_files.count

  Dragonborn.configure do
    root "#{TEST_DIR}/src/components"
    root "#{TEST_DIR}/src/systems"
  end

  assert.true! Object.const_defined?(:Clickable, false), "Clickable was not defined"
  assert.true! Object.const_defined?(:Hoverable, false), "Hoverable was not defined"
  assert.true! Object.const_defined?(:MouseSystem, false), "MouseSystem was not defined"
  assert.true! Object.const_defined?(:KeyboardSystem, false), "KeyboardSystem was not defined"

  assert.equal! $gtk.required_files.drop(already_loaded), %W[
    #{TEST_DIR}/src/components/clickable.rb
    #{TEST_DIR}/src/components/hoverable.rb
    #{TEST_DIR}/src/systems/keyboard_system.rb
    #{TEST_DIR}/src/systems/mouse_system.rb
  ]
end
