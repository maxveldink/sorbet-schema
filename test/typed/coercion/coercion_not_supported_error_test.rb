# typed: true

require "test_helper"

class CoercionNotSupportedErrorTest < Minitest::Test
  def test_formats_message
    error = Typed::Coercion::CoercionNotSupportedError.new(type: T::Utils.coerce(RubyRank), value: "unknown")

    assert_equal('Coercer not found for type RubyRank. Value: "unknown" (String).', error.message)
  end

  def test_accepts_the_existing_type_only_constructor
    error = Typed::Coercion::CoercionNotSupportedError.new(type: T::Utils.coerce(RubyRank))

    assert_equal("Coercer not found for type RubyRank. Value: nil (NilClass).", error.message)
  end
end
