require "lib/dragonborn"
require "support/testing.rb"

TEST_DIR = File.dirname(__FILE__)

def test_constants_autoload_properly(args, assert)
  begin
    Dragonborn.configure { root "#{TEST_DIR}/src" }
  rescue RuntimeError => e
    assert.equal! e.message, <<~MSG.rstrip
      [Dragonborn] Encountered issues:
        The file #{TEST_DIR}/src/array.rb masks Array
    MSG

    return true
  rescue => e
    puts e.inspect
    puts e.backtrace
  end

  raise "Test did not raise the expected error"
end
