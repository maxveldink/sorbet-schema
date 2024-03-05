# typed: true

require "test_helper"

class JSONSerializerTest < Minitest::Test
  def setup
    @serializer = Typed::JSONSerializer.new(schema: Person.create_schema)
  end

  # Serialize Tests

  def test_it_can_simple_serialize
    max = Person.new(name: "Max", age: 29)

    assert_equal('{"name":"Max","age":29}', @serializer.serialize(max))
  end

  def test_it_can_serialize_with_nested_struct
    hank = Person.new(name: "Hank", age: 38, job: Job.new(title: "Software Developer", salary: 90_000_00))

    assert_equal('{"name":"Hank","age":38,"job":{"title":"Software Developer","salary":9000000}}', @serializer.serialize(hank))
  end

  # Deserialize Tests

  def test_it_can_simple_deserialize
    hank_json = '{"name":"Hank","age":38,"job":{"title":"Software Developer","salary":9000000}}'

    result = @serializer.deserialize(hank_json)

    assert_success(result)
    assert_payload(Person.new(name: "Hank", age: 38, job: Job.new(title: "Software Developer", salary: 90_000_00)), result)
  end

  def test_it_can_deserialize_with_nested_object
    hank_json = '{"name":"Hank","age":38,"job":{"title":"Software Developer","salary":9000000}}'

    result = @serializer.deserialize(hank_json)

    assert_success(result)
    assert_payload(Person.new(name: "Hank", age: 38, job: Job.new(title: "Software Developer", salary: 90_000_00)), result)
  end

  def test_it_reports_on_parse_errors_on_deserialize
    max_json = '{"name": "Max", age": 29}' # Missing quotation

    result = @serializer.deserialize(max_json)

    assert_failure(result)
    assert_error(Typed::ParseError.new(format: :json), result)
  end

  def test_it_reports_validation_errors_on_deserialize
    max_json = '{"name": "Max"}'

    result = @serializer.deserialize(max_json)

    assert_failure(result)
    assert_error(Typed::Validations::RequiredFieldError.new(field_name: :age), result)
  end

  def test_it_reports_multiple_validation_errors_on_deserialize
    max_json = "{}"

    result = @serializer.deserialize(max_json)

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
