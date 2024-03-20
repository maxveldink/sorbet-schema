# typed: true

class BooleanCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::BooleanCoercer.new
    @type = T::Utils.coerce(T::Boolean)
  end

  def test_used_for_type_works
    assert(@coercer.used_for_type?(@type))
    refute(@coercer.used_for_type?(T::Utils.coerce(Integer)))
  end

  def test_when_non_boolean_type_given_returns_failure
    result = @coercer.coerce(type: T::Utils.coerce(Integer), value: "testing")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Type must be a T::Boolean."), result)
  end

  def test_when_true_class_returns_success
    result = @coercer.coerce(type: @type, value: true)

    assert_success(result)
    assert_payload(true, result)
  end

  def test_when_true_boolean_can_be_coerced_returns_success
    result = @coercer.coerce(type: @type, value: "true")

    assert_success(result)
    assert_payload(true, result)
  end

  def test_when_false_class_returns_success
    result = @coercer.coerce(type: @type, value: false)

    assert_success(result)
    assert_payload(false, result)
  end

  def test_when_false_boolean_can_be_coerced_returns_success
    result = @coercer.coerce(type: @type, value: "false")

    assert_success(result)
    assert_payload(false, result)
  end

  def test_when_enum_cannot_be_coerced_returns_failure
    result = @coercer.coerce(type: @type, value: "bad")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new, result)
  end
end
