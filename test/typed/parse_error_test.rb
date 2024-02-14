# typed: true

require "test_helper"

class ParseErrorTest < Minitest::Test
  def test_message_is_formatted
    assert_equal("max_markup could not be parsed. Check for typos.", Typed::ParseError.new(format: :max_markup).message)
  end
end
