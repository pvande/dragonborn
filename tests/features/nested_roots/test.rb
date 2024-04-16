require "lib/dragonborn"
require "support/testing.rb"

TEST_DIR = File.dirname(__FILE__)

def test_constants_autoload_properly(args, assert)
  already_loaded = $gtk.required_files.count

  Dragonborn.configure do
    root "#{TEST_DIR}/src/lib"
    root "#{TEST_DIR}/src/lib/entities"
  end

  assert.true! Object.const_defined?(:Scene, false), "Scene was not defined"
  assert.true! Object.const_defined?(:Stages, false), "Stages was not defined"
  assert.true! Object.const_defined?(:Car, false), "Car was not defined"
  assert.true! Object.const_defined?(:Static, false), "Static was not defined"
  assert.true! Static.const_defined?(:Billboard, false), "Billboard was not defined"
  assert.true! Stages.const_defined?(:StageOne, false), "Stages::StageOne was not defined"
  assert.true! Stages.const_defined?(:StageTwo, false), "Stages::StageTwo was not defined"

  assert.equal! $gtk.required_files.drop(already_loaded), %W[
    #{TEST_DIR}/src/lib/entities/car.rb
    #{TEST_DIR}/src/lib/entities/static/billboard.rb
    #{TEST_DIR}/src/lib/scene.rb
    #{TEST_DIR}/src/lib/stages/stage_one.rb
    #{TEST_DIR}/src/lib/stages/stage_two.rb
  ]
end
