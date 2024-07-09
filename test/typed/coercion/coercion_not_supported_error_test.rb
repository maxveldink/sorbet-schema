# typed: true

require "test_helper"

class CoercionNotSupportedErrorTest < Minitest::Test
  def test_formats_message
    error = Typed::Coercion::CoercionNotSupportedError.new(type: T::Utils.coerce(RubyRank))

    assert_equal("Coercer not found for type RubyRank.", error.message)
  end
end
