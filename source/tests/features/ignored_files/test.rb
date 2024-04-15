require "lib/dragonborn"
require "support/testing.rb"

TEST_DIR = File.dirname(__FILE__)

def test_constants_autoload_properly(args, assert)
  already_loaded = $gtk.required_files.count

  Dragonborn.configure do
    root "#{TEST_DIR}/src"

    ignore "#{TEST_DIR}/src/ignored"
    ignore "#{TEST_DIR}/src/entities/unconventional"
  end

  assert.true! Object.const_defined?(:Entity, false), "Entity was not defined"
  assert.true! Object.const_defined?(:Scene, false), "Scene was not defined"
  assert.true! Object.const_defined?(:Entities, false), "Entities was not defined"
  assert.true! Entities.const_defined?(:Player, false), "Player was not defined"

  assert.equal! $gtk.required_files.drop(already_loaded), %W[
    #{TEST_DIR}/src/entity.rb
    #{TEST_DIR}/src/entities/player.rb
    #{TEST_DIR}/src/scene.rb
  ]
end
