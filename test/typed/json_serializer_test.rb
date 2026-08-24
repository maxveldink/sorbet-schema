# typed: true

require "test_helper"

class JSONSerializerTest < Minitest::Test
  def setup
    @serializer = Typed::JSONSerializer.new(schema: Typed::Schema.from_struct(Person))
  end

  # Serialize Tests

  def test_it_round_trips_through_the_props_serialized_name
    serializer = Typed::JSONSerializer.new(schema: Typed::Schema.from_struct(WebhookPayload))
    payload = WebhookPayload.new(event_id: "evt-1", email_address: "user@example.com")

    serialized = serializer.serialize(payload)

    assert_success(serialized)
    assert_equal('{"eventId":"evt-1","emailAddress":"user@example.com","retries":0}', serialized.payload)
    assert_payload(payload, serializer.deserialize(serialized.payload))
  end

  def test_it_can_simple_serialize
    result = @serializer.serialize(MAX_PERSON)

    assert_success(result)
    assert_payload('{"name":"Max","age":29,"stone_rank":"shiny"}', result)
  end

  def test_it_can_serialize_with_nested_struct
    result = @serializer.serialize(ALEX_PERSON)

    assert_success(result)
    assert_payload('{"name":"Alex","age":31,"stone_rank":"pretty","job":{"title":"Software Developer","salary":{"cents":9000000,"currency":"USD"},"needs_credential":false}}', result)
  end

  def test_with_boolean_it_can_serialize
    result = Typed::JSONSerializer.new(schema: Typed::Schema.from_struct(City)).serialize(NEW_YORK_CITY)

    assert_success(result)
    assert_payload('{"name":"New York","capital":false}', result)
  end

  def test_with_array_it_can_serialize
    result = Typed::JSONSerializer.new(schema: Typed::Schema.from_struct(Country)).serialize(US_COUNTRY)

    assert_success(result)
    assert_payload('{"name":"US","cities":[{"name":"New York","capital":false},{"name":"DC","capital":true}],"national_items":{"bird":"bald eagle","anthem":"The Star-Spangled Banner"}}', result)
  end

  def test_will_use_inline_serializers
    result = Typed::JSONSerializer.new(schema: JOB_SCHEMA_WITH_INLINE_SERIALIZER).serialize(DEVELOPER_JOB_WITH_START_DATE)

    assert_success(result)
    assert_payload('{"title":"Software Developer","salary":{"cents":9000000,"currency":"USD"},"start_date":"061 March"}', result)
  end

  # Deserialize Tests

  def test_it_can_simple_deserialize
    result = @serializer.deserialize('{"name":"Max","age":29,"stone_rank":"shiny"}')

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_with_boolean_it_can_deserialize
    result = Typed::JSONSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize('{"name":"New York","capital":false}')

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_with_boolean_string_false_it_can_deserialize
    result = Typed::JSONSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize('{"name":"New York","capital":"false"}')

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_with_boolean_string_true_it_can_deserialize
    result = Typed::JSONSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize('{"name":"DC","capital":"true"}')

    assert_success(result)
    assert_payload(DC_CITY, result)
  end

  def test_with_array_it_can_deep_deserialize
    result = Typed::JSONSerializer.new(schema: Typed::Schema.from_struct(Country)).deserialize('{"name":"US","cities":[{"name":"New York","capital":false},{"name":"DC","capital":true}],"national_items":{"bird":"bald eagle","anthem":"The Star-Spangled Banner"}}')

    assert_success(result)
    assert_payload(US_COUNTRY, result)
  end

  def test_it_can_deserialize_with_nested_object
    result = @serializer.deserialize('{"name":"Alex","age":31,"stone_rank":"pretty","job":{"title":"Software Developer","salary":{"cents":9000000,"currency":"USD"}}}')

    assert_success(result)
    assert_payload(ALEX_PERSON, result)
  end

  def test_it_reports_on_parse_errors_on_deserialize
    result = @serializer.deserialize('{"name": "Max", age": 29, "stone_rank": "shiny"}') # Missing quotation

    assert_failure(result)
    assert_error(Typed::ParseError.new(format: :json), result)
  end

  def test_it_reports_validation_errors_on_deserialize
    result = @serializer.deserialize('{"name": "Max", "stone_rank": "shiny"}')

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
          Typed::Validations::RequiredFieldError.new(field_name: :stone_rank)
        ]
      ),
      result
    )
  end
end
