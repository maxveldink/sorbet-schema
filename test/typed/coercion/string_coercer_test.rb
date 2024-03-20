# typed: true

class StringCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::StringCoercer.new
    @type = T::Utils.coerce(String)
  end

  def test_used_for_type_works
    assert(@coercer.used_for_type?(@type))
    refute(@coercer.used_for_type?(T::Utils.coerce(Integer)))
  end

  def test_when_non_string_type_given_returns_failure
    result = @coercer.coerce(type: T::Utils.coerce(Integer), value: "testing")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Type must be a String."), result)
  end

  def test_returns_success
    assert_payload("1", @coercer.coerce(type: @type, value: 1))
    assert_payload("[1, 2]", @coercer.coerce(type: @type, value: [1, 2]))
  end
end
