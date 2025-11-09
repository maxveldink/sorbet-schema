# typed: true

class SymbolCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::SymbolCoercer.new
    @type = T::Utils.coerce(Symbol)
  end

  def test_used_for_type_works
    assert(@coercer.class.used_for_type?(@type))
    refute(@coercer.class.used_for_type?(T::Utils.coerce(Integer)))
  end

  def test_when_non_symbol_type_given_returns_failure
    result = @coercer.coerce(type: T::Utils.coerce(Integer), value: "testing")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Type must be a Symbol."), result)
  end

  def test_returns_success
    assert_payload(:testing, @coercer.coerce(type: @type, value: "testing"))
  end

  def test_returns_failure_if_value_cannot_be_coerced
    assert_error(Typed::Coercion::CoercionError.new("Value cannot be coerced into Symbol. Consider adding a #to_sym implementation."), @coercer.coerce(type: @type, value: 1))
  end
end
