# typed: true

class StructCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::StructCoercer.new
    @type = T::Utils.coerce(Job)
  end

  def test_used_for_type_works
    assert(@coercer.used_for_type?(@type))
    refute(@coercer.used_for_type?(T::Utils.coerce(T::Struct)))
    refute(@coercer.used_for_type?(T::Utils.coerce(Integer)))
  end

  def test_when_non_struct_type_given_returns_failure
    result = @coercer.coerce(type: T::Utils.coerce(Integer), value: {})

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Field type must inherit from T::Struct for Struct coercion."), result)
  end

  def test_when_struct_of_correct_type_given_returns_success
    result = @coercer.coerce(type: @type, value: DEVELOPER_JOB)

    assert_success(result)
    assert_payload(DEVELOPER_JOB, result)
  end

  def test_when_struct_of_incorrect_type_given_returns_failure
    result = @coercer.coerce(type: @type, value: Country.new(name: "Canada", cities: []))

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Value of type 'Country' cannot be coerced to Job Struct."), result)
  end

  def test_when_struct_can_be_coerced_returns_success
    result = @coercer.coerce(type: @type, value: {"title" => "Software Developer", :salary => 90_000_00})

    assert_success(result)
    assert_payload(DEVELOPER_JOB, result)
  end

  def test_when_value_is_not_a_hash_returns_failure
    result = @coercer.coerce(type: @type, value: "bad")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Value of type 'String' cannot be coerced to Job Struct."), result)
  end

  def test_when_struct_cannot_be_coerced_returns_failure
    result = @coercer.coerce(type: @type, value: {"not" => "valid"})

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Given hash could not be coerced to Job."), result)
  end
end
