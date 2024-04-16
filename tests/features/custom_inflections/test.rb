require "lib/dragonborn"
require "support/testing.rb"

TEST_DIR = File.dirname(__FILE__)

def test_constants_autoload_properly(args, assert)
  already_loaded = $gtk.required_files.count

  Dragonborn.configure do
    root "#{TEST_DIR}/src"

    inflection "ui" => "UI"
    inflection "url" => "URL"
    inflection "elf_archer" => "Legolas"
  end

  assert.true! Object.const_defined?(:Models, false), "Models was not defined"
  assert.true! Object.const_defined?(:UI, false), "UI was not defined"
  assert.true! Models.const_defined?(:DwarfRogue, false), "DwarfRogue was not defined"
  assert.true! Models.const_defined?(:Legolas, false), "Legolas was not defined"
  assert.true! Models.const_defined?(:HalfElfArcher, false), "HalfElfArcher was not defined"
  assert.true! UI.const_defined?(:Button, false), "Button was not defined"
  assert.true! UI.const_defined?(:LinkToURL, false), "LinkToURL was not defined"

  assert.equal! $gtk.required_files.drop(already_loaded), %W[
    #{TEST_DIR}/src/models/dwarf_rogue.rb
    #{TEST_DIR}/src/models/elf_archer.rb
    #{TEST_DIR}/src/models/half_elf_archer.rb
    #{TEST_DIR}/src/ui/button.rb
    #{TEST_DIR}/src/ui/link_to_url.rb
  ]
end
