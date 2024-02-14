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

    assert_predicate(result, :success?)
    assert_equal(PersonSchema.target.new(name: "Max", age: 29), result.payload)
  end

  def test_it_reports_on_parse_errors_on_deserialize
    max_json = '{"name": "Max", age": 29}' # Missing quotation

    result = @serializer.deserialize(max_json)

    assert_predicate(result, :failure?)
    assert_equal(Typed::ParseError.new(format: :json), result.error)
  end

  def test_it_reports_validation_errors_on_deserialize
    max_json = '{"name": "Max"}'

    result = @serializer.deserialize(max_json)

    assert_predicate(result, :failure?)
    assert_equal(Typed::RequiredFieldError.new(field_name: :age), result.error)
  end

  def test_it_reports_multiple_validation_errors_on_deserialize
    max_json = "{}"

    result = @serializer.deserialize(max_json)

    assert_predicate(result, :failure?)
    assert_equal(Typed::MultipleValidationError.new(errors: [Typed::RequiredFieldError.new(field_name: :name), Typed::RequiredFieldError.new(field_name: :age)]), result.error)
  end
end
