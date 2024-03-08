# typed: true

class IntegerCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::IntegerCoercer.new
    @field = Typed::Field.new(name: :testing, type: Integer)
  end

  def test_used_for_type_works
    assert(@coercer.used_for_type?(Integer))
    refute(@coercer.used_for_type?(Float))
  end

  def test_when_coercable_returns_success
    assert_payload(1, @coercer.coerce(field: @field, value: "1"))
    assert_payload(1, @coercer.coerce(field: @field, value: 1.1))
  end

  def test_when_not_coercable_returns_failure
    assert_error(Typed::Coercion::CoercionError.new("'a' cannot be coerced into Integer."), @coercer.coerce(field: @field, value: "a"))
    assert_error(Typed::Coercion::CoercionError.new("'true' cannot be coerced into Integer."), @coercer.coerce(field: @field, value: true))
  end
end
