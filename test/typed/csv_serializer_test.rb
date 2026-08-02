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

  def test_it_fails_to_serialize_when_a_field_remains_nested_despite_other_inline_serializers
    result = Typed::CSVSerializer.new(schema: JOB_SCHEMA_WITH_INLINE_SERIALIZER).serialize(DEVELOPER_JOB_WITH_START_DATE)

    assert_failure(result)
    assert_error(Typed::SerializeError.new("'Job' cannot be serialized to CSV because field(s) salary are not scalar values."), result)
  end

  def test_it_fails_to_serialize_a_struct_with_a_nested_struct_field
    result = @serializer.serialize(ALEX_PERSON)

    assert_failure(result)
    assert_error(Typed::SerializeError.new("'Person' cannot be serialized to CSV because field(s) job are not scalar values."), result)
  end

  def test_it_fails_to_serialize_a_struct_with_array_and_hash_fields
    country_serializer = Typed::CSVSerializer.new(schema: Typed::Schema.from_struct(Country))
    result = country_serializer.serialize(US_COUNTRY)

    assert_failure(result)
    assert_error(Typed::SerializeError.new("'Country' cannot be serialized to CSV because field(s) cities, national_items are not scalar values."), result)
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

  def test_it_raises_a_clear_error_when_csv_gem_is_unavailable
    with_gem_unavailable("csv", :CSV) do
      error = assert_raises(ArgumentError) { Typed::CSVSerializer.new(schema: Typed::Schema.from_struct(Person)) }
      assert_equal("csv gem is required for CSV serialization - add it to your Gemfile", error.message)
    end
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
