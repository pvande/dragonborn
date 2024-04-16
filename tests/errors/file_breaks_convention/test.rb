require "lib/dragonborn"
require "support/testing.rb"

TEST_DIR = File.dirname(__FILE__)

def test_constants_autoload_properly(args, assert)
  begin
    Dragonborn.configure { root "#{TEST_DIR}/src" }
  rescue Dragonborn::Loader::LoadError => e
    assert.equal! e.message, "Expected #{TEST_DIR}/src/baz.rb to define Baz!"
    return true
  rescue => e
    puts e.inspect
    puts e.backtrace
  end

  raise "Test did not raise the expected error"
end
