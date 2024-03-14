# typed: true

class StructCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::StructCoercer.new
  end

  def test_used_for_type_works
    assert(@coercer.used_for_type?(Job))
    refute(@coercer.used_for_type?(T::Struct))
    refute(@coercer.used_for_type?(Integer))
  end

  def test_when_non_struct_field_given_returns_failure
    result = @coercer.coerce(type: Integer, value: "testing")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Field type must inherit from T::Struct for Struct coercion."), result)
  end

  def test_when_struct_can_be_coerced_returns_success
    result = @coercer.coerce(type: Job, value: {"title" => "Software Developer", "salary" => 90_000_00})

    assert_success(result)
    assert_payload(Job.new(title: "Software Developer", salary: 90_000_00), result)
  end

  def test_when_struct_cannot_be_coerced_returns_failure
    result = @coercer.coerce(type: Job, value: "bad")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Value must be a Hash for Struct coercion."), result)
  end
end
