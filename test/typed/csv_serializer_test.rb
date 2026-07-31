# typed: true

require "test_helper"

class CSVSerializerTest < Minitest::Test
  def setup
    @serializer = Typed::CSVSerializer.new(schema: Typed::Schema.from_struct(Person))
  end

  # Serialize Tests

  def test_it_can_simple_serialize
    result = @serializer.serialize(MAX_PERSON)

    assert_success(result)
    assert_payload("name,age,stone_rank\nMax,29,shiny\n", result)
  end

  def test_with_boolean_it_can_serialize
    result = Typed::CSVSerializer.new(schema: Typed::Schema.from_struct(City)).serialize(NEW_YORK_CITY)

    assert_success(result)
    assert_payload("name,capital\nNew York,false\n", result)
  end

  def test_when_struct_given_is_not_of_target_type_returns_failure
    result = @serializer.serialize(DEVELOPER_JOB)

    assert_failure(result)
    assert_error(Typed::SerializeError.new("'Job' cannot be serialized to target type of 'Person'."), result)
  end

  def test_will_use_inline_serializers
    result = Typed::CSVSerializer.new(schema: JOB_SCHEMA_WITH_INLINE_SERIALIZER).serialize(DEVELOPER_JOB_WITH_START_DATE)

    assert_success(result)
    assert_payload("title,salary,start_date\nSoftware Developer,\"{cents: 9000000, currency: \"\"USD\"\"}\",061 March\n", result)
  end

  # CSV is a flat, row-based format: nested structs, hashes, and arrays cannot be
  # represented as their own columns. They are serialized using their Ruby `to_s`
  # representation instead, which is not reconstructable back into the original
  # struct/hash/array shape. Prefer this serializer for schemas with scalar fields.

  def test_it_serializes_nested_structs_as_an_unstructured_string
    result = @serializer.serialize(ALEX_PERSON)

    assert_success(result)
    assert_payload("name,age,stone_rank,job\nAlex,31,pretty,\"{title: \"\"Software Developer\"\", salary: {cents: 9000000, currency: \"\"USD\"\"}, needs_credential: false}\"\n", result)
  end

  def test_it_cannot_deserialize_a_previously_serialized_nested_struct
    serialized = @serializer.serialize(ALEX_PERSON)
    result = @serializer.deserialize(serialized.payload)

    assert_failure(result)
    assert_error(Typed::Validations::ValidationError.new("Value of type 'String' cannot be coerced to Job Struct."), result)
  end

  def test_it_cannot_deserialize_a_previously_serialized_array_field
    country_serializer = Typed::CSVSerializer.new(schema: Typed::Schema.from_struct(Country))
    serialized = country_serializer.serialize(US_COUNTRY)
    result = country_serializer.deserialize(serialized.payload)

    assert_failure(result)
    assert_error(
      Typed::Validations::MultipleValidationError.new(
        errors: [
          Typed::Validations::ValidationError.new("Value must be an Array."),
          Typed::Validations::ValidationError.new("Value must be a Hash.")
        ]
      ),
      result
    )
  end

  # Deserialize Tests

  def test_it_can_simple_deserialize
    result = @serializer.deserialize("name,age,stone_rank\nMax,29,shiny\n")

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_with_boolean_it_can_deserialize
    result = Typed::CSVSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize("name,capital\nNew York,false\n")

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_with_boolean_string_false_it_can_deserialize
    result = Typed::CSVSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize("name,capital\nNew York,\"false\"\n")

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_with_boolean_string_true_it_can_deserialize
    result = Typed::CSVSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize("name,capital\nDC,\"true\"\n")

    assert_success(result)
    assert_payload(DC_CITY, result)
  end

  def test_it_reports_on_parse_errors_on_deserialize
    result = @serializer.deserialize("name,age,stone_rank\n\"Max,29,shiny")

    assert_failure(result)
    assert_error(Typed::ParseError.new(format: :csv), result)
  end

  def test_it_reports_a_parse_error_when_csv_has_no_rows
    result = @serializer.deserialize("")

    assert_failure(result)
    assert_error(Typed::ParseError.new(format: :csv), result)
  end

  def test_it_reports_validation_errors_on_deserialize
    result = @serializer.deserialize("name,stone_rank\nMax,shiny\n")

    assert_failure(result)
    assert_error(Typed::Validations::RequiredFieldError.new(field_name: :age), result)
  end

  def test_it_reports_multiple_validation_errors_on_deserialize
    result = @serializer.deserialize("name\n\n")

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
