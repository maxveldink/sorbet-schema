# typed: true

class IntegerCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::IntegerCoercer.new
    @type = T::Utils.coerce(Integer)
  end

  def test_used_for_type_works
    assert(@coercer.class.used_for_type?(@type))
    refute(@coercer.class.used_for_type?(T::Utils.coerce(Float)))
  end

  def test_when_non_integer_type_given_returns_failure
    result = @coercer.coerce(type: T::Utils.coerce(Float), value: 1.0)

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Type must be a Integer."), result)
  end

  def test_when_coercable_returns_success
    assert_payload(1, @coercer.coerce(type: @type, value: "1"))
    assert_payload(1, @coercer.coerce(type: @type, value: 1.1))
  end

  def test_when_not_coercable_returns_failure
    assert_error(Typed::Coercion::CoercionError.new("'a' cannot be coerced into Integer."), @coercer.coerce(type: @type, value: "a"))
    assert_error(Typed::Coercion::CoercionError.new("'true' cannot be coerced into Integer."), @coercer.coerce(type: @type, value: true))
  end
end
