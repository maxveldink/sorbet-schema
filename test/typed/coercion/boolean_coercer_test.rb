# typed: true

class BooleanCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::BooleanCoercer.new
    @type = T::Utils.coerce(T::Boolean)
  end

  def test_used_for_type_works
    assert(@coercer.used_for_type?(@type))
    refute(@coercer.used_for_type?(Integer))
  end

  def test_when_non_boolean_field_given_returns_failure
    result = @coercer.coerce(type: Integer, value: "testing")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Field type must be a T::Boolean."), result)
  end

  def test_when_true_boolean_can_be_coerced_returns_success
    result = @coercer.coerce(type: @type, value: "true")

    assert_success(result)
    assert_payload(true, result)
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
