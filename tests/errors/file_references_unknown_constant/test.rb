require "lib/dragonborn"
require "support/testing.rb"

TEST_DIR = File.dirname(__FILE__)

def test_constants_autoload_properly(args, assert)
  begin
    Dragonborn.configure { root "#{TEST_DIR}/src" }
  rescue NameError => e
    assert.equal! e.message, <<~MSG.rstrip
      * EXCEPTION: ~Runtime#add_to_require_queue~ failed for =#{TEST_DIR}/src/baz.rb=.
      uninitialized constant Glormp
    MSG

    return true
  rescue => e
    puts e.inspect
    puts e.backtrace
  end

  raise "Test did not raise the expected error"
end
