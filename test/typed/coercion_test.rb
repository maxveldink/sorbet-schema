# typed: true

require "bigdecimal"

class DecimalStringIntegerCoercer < Typed::Coercion::Coercer
  extend T::Generic

  Target = type_member { {fixed: Integer} }

  sig { override.params(type: T::Types::Base).returns(T::Boolean) }
  def self.used_for_type?(type)
    type == T::Utils.coerce(Integer)
  end

  sig { override.params(type: T::Types::Base, value: Typed::Value).returns(Typed::Result[Target, Typed::Coercion::CoercionError]) }
  def coerce(type:, value:)
    return Typed::Failure.new(Typed::Coercion::CoercionError.new("Type must be an Integer.")) unless self.class.used_for_type?(type)

    Typed::Success.new(T.unsafe(value).to_i)
  end
end

class DecimalStringIntegerStruct < T::Struct
  const :amount, Integer
end

class CoercionTest < Minitest::Test
  def teardown
    Typed::Coercion::CoercerRegistry.instance.reset!
  end

  def test_new_coercers_can_be_registered
    Typed::Coercion.register_coercer(SimpleStringCoercer)

    assert_equal(SimpleStringCoercer, Typed::Coercion::CoercerRegistry.instance.select_coercer_by(type: T::Utils.coerce(String)))
  end

  def test_registered_integer_coercer_can_deserialize_decimal_string
    Typed::Coercion.register_coercer(DecimalStringIntegerCoercer)

    result = DecimalStringIntegerStruct.deserialize_from(:hash, {amount: "2600.0"})

    assert_success(result)
    assert_equal(2600, result.payload.amount)
  end

  def test_when_coercer_is_matched_coerce_coerces
    result = Typed::Coercion.coerce(type: T::Utils.coerce(String), value: 1)

    assert_success(result)
    assert_payload("1", result)
  end

  def test_when_coercer_isnt_matched_coerce_returns_failure
    result = Typed::Coercion.coerce(type: T::Utils.coerce(BigDecimal), value: "testing")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionNotSupportedError.new(type: T::Utils.coerce(BigDecimal)), result)
  end
end
