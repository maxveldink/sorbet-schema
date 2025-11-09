# typed: true

require "test_helper"

class DateCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::DateCoercer.new
    @type = T::Utils.coerce(Date)
  end

  def test_used_for_type_works
    assert(@coercer.class.used_for_type?(@type))
    refute(@coercer.class.used_for_type?(T::Utils.coerce(Integer)))
  end

  def test_when_non_date_type_given_returns_failure
    result = @coercer.coerce(type: T::Utils.coerce(Integer), value: Date.new(2024, 1, 1))

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Type must be a Date."), result)
  end

  def test_when_coercable_returns_success
    assert_payload(Date.new(2024, 1, 1), @coercer.coerce(type: @type, value: "20240101"))
    assert_payload(Date.new(2024, 5, 1), @coercer.coerce(type: @type, value: "1/5/2024"))
    assert_payload(Date.new(2024, 5, 1), @coercer.coerce(type: @type, value: Date.new(2024, 5, 1)))
  end

  def test_when_not_coercable_returns_failure
    assert_error(Typed::Coercion::CoercionError.new("'a' cannot be coerced into Date."), @coercer.coerce(type: @type, value: "a"))
    assert_error(Typed::Coercion::CoercionError.new("'1' cannot be coerced into Date."), @coercer.coerce(type: @type, value: 1))
  end
end
