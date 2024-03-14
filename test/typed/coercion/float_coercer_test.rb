# typed: true

class FloatCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::FloatCoercer.new
    @type = Float
  end

  def test_used_for_type_works
    assert(@coercer.used_for_type?(Float))
    refute(@coercer.used_for_type?(Integer))
  end

  def test_when_coercable_returns_success
    assert_payload(1.1, @coercer.coerce(type: @type, value: "1.1"))
    assert_payload(1.0, @coercer.coerce(type: @type, value: 1))
  end

  def test_when_not_coercable_returns_failure
    assert_error(Typed::Coercion::CoercionError.new("'a' cannot be coerced into Float."), @coercer.coerce(type: @type, value: "a"))
    assert_error(Typed::Coercion::CoercionError.new("'true' cannot be coerced into Float."), @coercer.coerce(type: @type, value: true))
  end
end
