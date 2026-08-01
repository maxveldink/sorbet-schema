# typed: true

require "test_helper"

class YMLSerializerTest < Minitest::Test
  def setup
    @serializer = Typed::YMLSerializer.new(schema: Typed::Schema.from_struct(Person))
  end

  # Serialize Tests

  def test_it_can_simple_serialize
    result = @serializer.serialize(MAX_PERSON)

    assert_success(result)
    assert_payload("---\nname: Max\nage: 29\nstone_rank: shiny\n", result)
  end

  def test_it_can_serialize_with_nested_struct
    result = @serializer.serialize(ALEX_PERSON)

    assert_success(result)
    assert_payload("---\nname: Alex\nage: 31\nstone_rank: pretty\njob:\n  title: Software Developer\n  salary:\n    cents: 9000000\n    currency: USD\n  needs_credential: false\n", result)
  end

  def test_with_boolean_it_can_serialize
    result = Typed::YMLSerializer.new(schema: Typed::Schema.from_struct(City)).serialize(NEW_YORK_CITY)

    assert_success(result)
    assert_payload("---\nname: New York\ncapital: false\n", result)
  end

  def test_with_array_it_can_serialize
    result = Typed::YMLSerializer.new(schema: Typed::Schema.from_struct(Country)).serialize(US_COUNTRY)

    assert_success(result)
    assert_payload("---\nname: US\ncities:\n- name: New York\n  capital: false\n- name: DC\n  capital: true\nnational_items:\n  bird: bald eagle\n  anthem: The Star-Spangled Banner\n", result)
  end

  def test_when_struct_given_is_not_of_target_type_returns_failure
    result = @serializer.serialize(DEVELOPER_JOB)

    assert_failure(result)
    assert_error(Typed::SerializeError.new("'Job' cannot be serialized to target type of 'Person'."), result)
  end

  def test_will_use_inline_serializers
    result = Typed::YMLSerializer.new(schema: JOB_SCHEMA_WITH_INLINE_SERIALIZER).serialize(DEVELOPER_JOB_WITH_START_DATE)

    assert_success(result)
    assert_payload("---\ntitle: Software Developer\nsalary:\n  cents: 9000000\n  currency: USD\nstart_date: 061 March\n", result)
  end

  # Deserialize Tests

  def test_it_can_simple_deserialize
    result = @serializer.deserialize("---\nname: Max\nage: 29\nstone_rank: shiny\n")

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_with_boolean_it_can_deserialize
    result = Typed::YMLSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize("---\nname: New York\ncapital: false\n")

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_with_boolean_string_false_it_can_deserialize
    result = Typed::YMLSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize("---\nname: New York\ncapital: \"false\"\n")

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_with_boolean_string_true_it_can_deserialize
    result = Typed::YMLSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize("---\nname: DC\ncapital: \"true\"\n")

    assert_success(result)
    assert_payload(DC_CITY, result)
  end

  def test_with_array_it_can_deep_deserialize
    result = Typed::YMLSerializer.new(schema: Typed::Schema.from_struct(Country)).deserialize("---\nname: US\ncities:\n- name: New York\n  capital: false\n- name: DC\n  capital: true\nnational_items:\n  bird: bald eagle\n  anthem: The Star-Spangled Banner\n")

    assert_success(result)
    assert_payload(US_COUNTRY, result)
  end

  def test_it_can_deserialize_with_nested_object
    result = @serializer.deserialize("---\nname: Alex\nage: 31\nstone_rank: pretty\njob:\n  title: Software Developer\n  salary:\n    cents: 9000000\n    currency: USD\n")

    assert_success(result)
    assert_payload(ALEX_PERSON, result)
  end

  def test_it_reports_on_parse_errors_on_deserialize
    result = @serializer.deserialize("name: [unterminated")

    assert_failure(result)
    assert_error(Typed::ParseError.new(format: :yml), result)
  end

  def test_it_reports_a_parse_error_when_yaml_is_not_a_mapping
    result = @serializer.deserialize("just a plain scalar string")

    assert_failure(result)
    assert_error(Typed::ParseError.new(format: :yml), result)
  end

  def test_it_reports_validation_errors_on_deserialize
    result = @serializer.deserialize("---\nname: Max\nstone_rank: shiny\n")

    assert_failure(result)
    assert_error(Typed::Validations::RequiredFieldError.new(field_name: :age), result)
  end

  def test_it_reports_multiple_validation_errors_on_deserialize
    result = @serializer.deserialize("--- {}\n")

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
