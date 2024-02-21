# typed: true

require "test_helper"

class JSONSerializerTest < Minitest::Test
  def setup
    @serializer = Typed::JSONSerializer.new(schema: PersonSchema)
  end

  # Serialize Tests

  def test_it_can_simple_serialize
    max = PersonSchema.target.new(name: "Max", age: 29)

    assert_equal('{"name":"Max","age":29}', @serializer.serialize(max))
  end

  # Deserialize Tests

  def test_it_can_simple_deserialize
    max_json = '{"name": "Max", "age": 29}'

    result = @serializer.deserialize(max_json)

    assert_success(result)
    assert_payload(PersonSchema.target.new(name: "Max", age: 29), result)
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
