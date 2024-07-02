# typed: true

require "test_helper"

class TypedHashCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::TypedHashCoercer.new
    @type = T::Utils.coerce(T::Hash[String, Integer])
  end

  def test_used_for_type_works
    assert(@coercer.used_for_type?(T::Utils.coerce(T::Hash[String, Integer])))
    assert(@coercer.used_for_type?(T::Utils.coerce(T::Hash[String, String])))
    assert(@coercer.used_for_type?(T::Utils.coerce(Hash)))
    refute(@coercer.used_for_type?(T::Utils.coerce(Integer)))
  end

  def test_when_non_array_field_given_returns_failure
    result = @coercer.coerce(type: T::Utils.coerce(Integer), value: [1, 2])

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Field type must be a T::Array."), result)
  end

  def test_when_non_array_value_given_returns_failure
    result = @coercer.coerce(type: @type, value: "testing")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Value must be an Array."), result)
  end

  def test_when_already_of_type_returns_success
    result = @coercer.coerce(type: @type, value: [DC_CITY, NEW_YORK_CITY])

    assert_success(result)
    assert_payload([DC_CITY, NEW_YORK_CITY], result)
  end

  def test_when_coercable_array_can_be_coerced_returns_success
    result = @coercer.coerce(type: @type, value: [DC_CITY, {name: "New York", capital: false}])

    assert_success(result)
    assert_payload([DC_CITY, NEW_YORK_CITY], result)
  end

  def test_when_untyped_array_returns_success
    result = @coercer.coerce(type: T::Utils.coerce(Array), value: [DC_CITY, {name: "New York", capital: false}])

    assert_success(result)
    assert_payload([DC_CITY, {name: "New York", capital: false}], result)
  end

  def test_when_array_cannot_be_coerced_returns_failure
    result = @coercer.coerce(type: @type, value: [1, DC_CITY])

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Value of type 'Integer' cannot be coerced to City Struct."), result)
  end
end
