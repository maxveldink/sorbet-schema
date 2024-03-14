# typed: true

require "test_helper"

class JSONSerializerTest < Minitest::Test
  def setup
    @serializer = Typed::JSONSerializer.new(schema: Typed::Schema.from_struct(Person))
  end

  # Serialize Tests

  def test_it_can_simple_serialize
    result = @serializer.serialize(MAX_PERSON)

    assert_success(result)
    assert_payload('{"name":"Max","age":29,"ruby_rank":"shiny"}', result)
  end

  def test_it_can_serialize_with_nested_struct
    result = @serializer.serialize(ALEX_PERSON)

    assert_success(result)
    assert_payload('{"name":"Alex","age":31,"ruby_rank":"pretty","job":{"title":"Software Developer","salary":100000000}}', result)
  end

  def test_with_boolean_it_can_serialize
    result = Typed::JSONSerializer.new(schema: Typed::Schema.from_struct(City)).serialize(NEW_YORK_CITY)

    assert_success(result)
    assert_payload('{"name":"New York","capital":false}', result)
  end

  def test_with_array_it_can_serialize
    result = Typed::JSONSerializer.new(schema: Typed::Schema.from_struct(Country)).serialize(US_COUNTRY)

    assert_success(result)
    assert_payload('{"name":"US","cities":[{"name":"New York","capital":false},{"name":"DC","capital":true}]}', result)
  end

  # Deserialize Tests

  def test_it_can_simple_deserialize
    result = @serializer.deserialize('{"name":"Max","age":29,"ruby_rank":"shiny"}')

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_with_boolean_it_can_deserialize
    result = Typed::JSONSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize('{"name":"New York","capital":false}')

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_with_array_it_can_deep_deserialize
    result = Typed::JSONSerializer.new(schema: Typed::Schema.from_struct(Country)).deserialize('{"name":"US","cities":[{"name":"New York","capital":false},{"name":"DC","capital":true}]}')

    assert_success(result)
    assert_payload(US_COUNTRY, result)
  end

  def test_it_can_deserialize_with_nested_object
    result = @serializer.deserialize('{"name":"Alex","age":31,"ruby_rank":"pretty","job":{"title":"Software Developer","salary":100000000}}')

    assert_success(result)
    assert_payload(ALEX_PERSON, result)
  end

  def test_it_reports_on_parse_errors_on_deserialize
    result = @serializer.deserialize('{"name": "Max", age": 29, "ruby_rank": "shiny"}') # Missing quotation

    assert_failure(result)
    assert_error(Typed::ParseError.new(format: :json), result)
  end

  def test_it_reports_validation_errors_on_deserialize
    result = @serializer.deserialize('{"name": "Max", "ruby_rank": "shiny"}')

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
          Typed::Validations::RequiredFieldError.new(field_name: :age),
          Typed::Validations::RequiredFieldError.new(field_name: :ruby_rank)
        ]
      ),
      result
    )
  end
end
