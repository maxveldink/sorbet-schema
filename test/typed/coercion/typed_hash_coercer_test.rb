# typed: true

require "test_helper"

class TypedHashCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::TypedHashCoercer.new
    @type = T::Utils.coerce(T::Hash[String, Integer])
  end

  def test_used_for_type_works
    assert(@coercer.class.used_for_type?(T::Utils.coerce(T::Hash[String, Integer])))
    assert(@coercer.class.used_for_type?(T::Utils.coerce(T::Hash[String, String])))
    assert(@coercer.class.used_for_type?(T::Utils.coerce(Hash)))
    refute(@coercer.class.used_for_type?(T::Utils.coerce(Integer)))
  end

  def test_when_non_hash_field_given_returns_failure
    result = @coercer.coerce(type: T::Utils.coerce(Integer), value: {"test" => 1})

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Field type must be a T::Hash."), result)
  end

  def test_when_non_hash_value_given_returns_failure
    result = @coercer.coerce(type: @type, value: "testing")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Value must be a Hash."), result)
  end

  def test_when_already_of_type_returns_success
    result = @coercer.coerce(type: @type, value: {"test" => 1})

    assert_success(result)
    assert_payload({"test" => 1}, result)
  end

  def test_when_coercable_hash_can_be_coerced_returns_success
    result = @coercer.coerce(type: @type, value: {"test" => "1", 1 => 2})

    assert_success(result)
    assert_payload({"test" => 1, "1" => 2}, result)
  end

  def test_when_untyped_hash_returns_success
    result = @coercer.coerce(type: T::Utils.coerce(Hash), value: {"test" => 1})

    assert_success(result)
    assert_payload({"test" => 1}, result)
  end

  def test_immutable_struct_values_can_be_coerced
    city = ImmutableCity.new(name: "Ada", capital: false)
    result = @coercer.coerce(type: T::Utils.coerce(T::Hash[String, ImmutableCity]), value: {"home" => city, "capital" => {name: "DC", capital: true}})

    assert_success(result)
    assert_same(city, result.payload.fetch("home"))
    assert_instance_of(ImmutableCity, result.payload.fetch("capital"))
    assert_equal("DC", result.payload.fetch("capital").name)
    assert(result.payload.fetch("capital").frozen?)
  end

  def test_when_array_cannot_be_coerced_returns_failure
    result = @coercer.coerce(type: @type, value: {"test" => "test"})

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("'test' cannot be coerced into Integer."), result)
  end
end
