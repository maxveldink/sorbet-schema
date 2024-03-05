# typed: true

class HashSerializerTest < Minitest::Test
  def setup
    @serializer = Typed::HashSerializer.new(schema: Person.create_schema)
  end

  # Serialize Tests

  def test_it_can_simple_serialize
    max = Person.new(name: "Max", age: 29)

    assert_equal({name: "Max", age: 29}, @serializer.serialize(max))
  end

  def test_it_can_serialize_with_nested_struct
    hank = Person.new(name: "Hank", age: 38, job: Job.new(title: "Software Developer", salary: 90_000_00))

    assert_equal({name: "Hank", age: 38, job: {title: "Software Developer", salary: 90_000_00}}, @serializer.serialize(hank))
  end

  # Deserialize Tests

  def test_it_can_simple_deserialize
    max_hash = {name: "Max", age: 29}

    result = @serializer.deserialize(max_hash)

    assert_success(result)
    assert_payload(Person.new(name: "Max", age: 29), result)
  end

  def test_it_can_simple_deserialize_from_string_keys
    max_hash = {"name" => "Max", "age" => 29}

    result = @serializer.deserialize(max_hash)

    assert_success(result)
    assert_payload(Person.new(name: "Max", age: 29), result)
  end

  def test_it_can_deserialize_with_nested_object
    hank_hash = {name: "Hank", age: 38, job: {title: "Software Developer", salary: 90_000_00}}

    result = @serializer.deserialize(hank_hash)

    assert_success(result)
    assert_payload(Person.new(name: "Hank", age: 38, job: Job.new(title: "Software Developer", salary: 90_000_00)), result)
  end

  def test_it_reports_validation_errors_on_deserialize
    max_hash = {name: "Max"}

    result = @serializer.deserialize(max_hash)

    assert_failure(result)
    assert_error(Typed::Validations::RequiredFieldError.new(field_name: :age), result)
  end

  def test_it_reports_multiple_validation_errors_on_deserialize
    result = @serializer.deserialize({})

    assert_failure(result)
    assert_error(
      Typed::Validations::MultipleValidationError.new(
        errors: [
          Typed::Validations::RequiredFieldError.new(field_name: :name),
          Typed::Validations::RequiredFieldError.new(field_name: :age)
        ]
      ),
      result
    )
  end
end
