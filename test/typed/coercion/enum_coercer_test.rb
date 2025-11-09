# typed: true

class EnumCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::EnumCoercer.new
  end

  def test_used_for_type_works
    assert(@coercer.class.used_for_type?(T::Utils.coerce(RubyRank)))
    refute(@coercer.class.used_for_type?(T::Utils.coerce(T::Enum)))
    refute(@coercer.class.used_for_type?(T::Utils.coerce(Integer)))
  end

  def test_when_non_enum_field_given_returns_failure
    result = @coercer.coerce(type: T::Utils.coerce(Integer), value: "testing")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Field type must inherit from T::Enum for Enum coercion."), result)
  end

  def test_when_enum_can_be_coerced_returns_success
    result = @coercer.coerce(type: T::Utils.coerce(RubyRank), value: "shiny")

    assert_success(result)
    assert_payload(RubyRank::Luminary, result)
  end

  def test_when_enum_cannot_be_coerced_returns_failure
    result = @coercer.coerce(type: T::Utils.coerce(RubyRank), value: "bad")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Enum RubyRank key not found: \"bad\""), result)
  end
end
