# typed: true

require "bigdecimal"

class CoercionTest < Minitest::Test
  def teardown
    Typed::Coercion::CoercerRegistry.instance.reset!
  end

  def test_new_coercers_can_be_registered
    Typed::Coercion.register_coercer(SimpleStringCoercer)

    assert_equal(SimpleStringCoercer, Typed::Coercion::CoercerRegistry.instance.select_coercer_by(type: T::Utils.coerce(String)))
  end

  def test_when_coercer_is_matched_coerce_coerces
    result = Typed::Coercion.coerce(type: T::Utils.coerce(String), value: 1)

    assert_success(result)
    assert_payload("1", result)
  end

  def test_when_coercer_isnt_matched_coerce_returns_failure
    result = Typed::Coercion.coerce(type: T::Utils.coerce(BigDecimal), value: "testing")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionNotSupportedError.new, result)
  end
end
