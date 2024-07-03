require "lib/dragonborn"
require "support/testing.rb"

TEST_DIR = File.dirname(__FILE__)

def test_constants_autoload_properly(args, assert)
  begin
    Dragonborn.configure { root "#{TEST_DIR}/src" }
  rescue Exception => e
    assert.true! e.message.include?("=#{TEST_DIR}/src/baz.rb=")
    assert.true! e.message.include?("uninitialized constant Glormp")
  end
end
