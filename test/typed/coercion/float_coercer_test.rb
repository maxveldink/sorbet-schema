# typed: true

class FloatCoercerTest < Minitest::Test
  def setup
    @field = Typed::Field.new(name: :testing, type: Float)
  end

  def test_when_coercable_returns_success
    assert_payload(1.1, Typed::Coercion::FloatCoercer.new.coerce(field: @field, value: "1.1"))
    assert_payload(1.0, Typed::Coercion::FloatCoercer.new.coerce(field: @field, value: 1))
  end

  def test_when_not_coercable_returns_failure
    assert_error(Typed::Coercion::CoercionError.new("'a' cannot be coerced into Float."), Typed::Coercion::FloatCoercer.new.coerce(field: @field, value: "a"))
    assert_error(Typed::Coercion::CoercionError.new("'true' cannot be coerced into Float."), Typed::Coercion::FloatCoercer.new.coerce(field: @field, value: true))
  end
end
