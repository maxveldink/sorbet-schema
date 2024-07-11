# typed: true

require "test_helper"

class DateTimeCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::DateTimeCoercer.new
    @type = T::Utils.coerce(DateTime)
  end

  def test_used_for_type_works
    assert(@coercer.used_for_type?(@type))
    refute(@coercer.used_for_type?(T::Utils.coerce(Integer)))
  end

  def test_when_non_date_type_given_returns_failure
    result = @coercer.coerce(type: T::Utils.coerce(Integer), value: DateTime.now)

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Type must be a DateTime."), result)
  end

  def test_when_coercable_returns_success
    assert_payload(DateTime.new(2024, 7, 11, 19, 31, 30), @coercer.coerce(type: @type, value: "2024-07-11T19:31:30Z"))
    assert_payload(DateTime.new(2024, 7, 11, 19, 31, 30), @coercer.coerce(type: @type, value: "2024-07-11T19:31:30"))
    assert_payload(DateTime.new(2024, 7, 11), @coercer.coerce(type: @type, value: "2024-07-11"))
  end

  def test_when_not_coercable_returns_failure
    assert_error(Typed::Coercion::CoercionError.new("'a' cannot be coerced into DateTime."), @coercer.coerce(type: @type, value: "a"))
    assert_error(Typed::Coercion::CoercionError.new("'1' cannot be coerced into DateTime."), @coercer.coerce(type: @type, value: 1))
  end
end
