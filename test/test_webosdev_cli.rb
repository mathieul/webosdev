require File.join(File.dirname(__FILE__), "test_helper.rb")
require 'webosdev/cli'

class TestWebosdevCli < Test::Unit::TestCase
  def setup
    Webosdev::CLI.execute(@stdout_io = StringIO.new, [])
    @stdout_io.rewind
    @stdout = @stdout_io.read
  end
  
  def test_print_default_output
    assert_match(/To update this executable/, @stdout)
  end
end