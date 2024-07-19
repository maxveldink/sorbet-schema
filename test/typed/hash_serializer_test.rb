# typed: true

require "test_helper"

class HashSerializerTest < Minitest::Test
  class StructWithBooleanDefaultSetToTrue < T::Struct
    include ActsAsComparable

    const :tired, T::Boolean, default: true
  end

  class StructWithBooleanDefaultSetToFalse < T::Struct
    include ActsAsComparable

    const :tired, T::Boolean, default: false
  end

  def setup
    @serializer = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Person))
  end

  # Serialize Tests

  def test_it_can_simple_serialize
    result = @serializer.serialize(MAX_PERSON)

    assert_success(result)
    assert_payload({name: "Max", age: 29, stone_rank: RubyRank::Luminary}, result)
  end

  def test_it_can_serialize_with_nested_struct
    result = @serializer.serialize(ALEX_PERSON)

    assert_success(result)
    assert_payload({name: "Alex", age: 31, stone_rank: RubyRank::Brilliant, job: DEVELOPER_JOB}, result)
  end

  def test_it_can_deep_serialize
    serializer = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Person), should_serialize_values: true)

    result = serializer.serialize(ALEX_PERSON)

    assert_success(result)
    assert_payload({name: "Alex", age: 31, stone_rank: "pretty", job: {title: "Software Developer", salary: {cents: 9000000, currency: "USD"}, needs_credential: false}}, result)
  end

  def test_with_boolean_it_can_serialize
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(City)).serialize(NEW_YORK_CITY)

    assert_success(result)
    assert_payload({name: "New York", capital: false}, result)
  end

  def test_with_array_and_hash_it_can_serialize
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Country)).serialize(US_COUNTRY)

    assert_success(result)
    assert_payload({name: "US", cities: [NEW_YORK_CITY, DC_CITY], national_items: {bird: "bald eagle", anthem: "The Star-Spangled Banner"}}, result)
  end

  def test_with_array_it_can_deep_serialize
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Country), should_serialize_values: true).serialize(US_COUNTRY)

    assert_success(result)
    assert_payload({name: "US", cities: [{name: "New York", capital: false}, {name: "DC", capital: true}], national_items: {bird: "bald eagle", anthem: "The Star-Spangled Banner"}}, result)
  end

  def test_when_struct_given_is_not_of_target_type_returns_failure
    result = @serializer.serialize(DEVELOPER_JOB)

    assert_failure(result)
    assert_error(Typed::SerializeError.new("'Job' cannot be serialized to target type of 'Person'."), result)
  end

  def test_will_use_inline_serializers
    result = Typed::HashSerializer.new(schema: JOB_SCHEMA_WITH_INLINE_SERIALIZER, should_serialize_values: true).serialize(DEVELOPER_JOB_WITH_START_DATE)

    assert_success(result)
    assert_payload({title: "Software Developer", salary: {cents: 90_000_00, currency: "USD"}, start_date: "061 March"}, result)
  end

  def test_with_hash_field_with_string_keys_serializes
    result = Typed::HashSerializer.new(schema: City.schema).serialize(OVIEDO_CITY)

    assert_success(result)
    assert_payload({name: "Oviedo", capital: false, data: {"how many maxes live here?" => 1}}, result)
  end

  # Deserialize Tests

  def test_it_can_simple_deserialize
    result = @serializer.deserialize({name: "Max", age: 29, stone_rank: RubyRank::Luminary})

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_it_can_simple_deserialize_from_string_keys
    result = @serializer.deserialize({"name" => "Max", "age" => 29, "stone_rank" => RubyRank::Luminary})

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_with_boolean_it_can_deserialize
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize({name: "New York", capital: false})

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_with_array_it_can_deserialize
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Country)).deserialize({name: "US", cities: [NEW_YORK_CITY, DC_CITY], national_items: {bird: "bald eagle", anthem: "The Star-Spangled Banner"}})

    assert_success(result)
    assert_payload(US_COUNTRY, result)
  end

  def test_with_array_it_can_deep_deserialize
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Country)).deserialize({name: "US", cities: [{name: "New York", capital: false}, {name: "DC", capital: true}], national_items: {bird: "bald eagle", anthem: "The Star-Spangled Banner"}})

    assert_success(result)
    assert_payload(US_COUNTRY, result)
  end

  def test_it_can_deserialize_with_nested_object
    result = @serializer.deserialize({name: "Alex", age: 31, stone_rank: "pretty", job: {title: "Software Developer", salary: Money.new(cents: 90_000_00)}})

    assert_success(result)
    assert_payload(ALEX_PERSON, result)
  end

  def test_it_can_deserialize_something_that_is_the_first_of_multiple_types
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Person)).deserialize({name: "Max", age: 29, stone_rank: "shiny"})

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_it_can_deserialize_something_that_is_the_second_of_multiple_types
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Person)).deserialize({name: "Max", age: 29, stone_rank: "good"})

    assert_success(result)
    assert_payload(Person.new(name: "Max", age: 29, stone_rank: DiamondRank::Good), result)
  end

  def test_if_it_cannot_be_deserialized_against_something_with_multiple_types_it_will_fail
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Person)).deserialize({name: "Max", age: 29, stone_rank: "not valid"})

    assert_failure(result)
    assert_error(Typed::Validations::ValidationError.new('Enum RubyRank key not found: "not valid", Enum DiamondRank key not found: "not valid"'), result)
  end

  def test_it_can_deserialize_with_default_value_boolean_true
    serializer = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(StructWithBooleanDefaultSetToTrue))
    result = serializer.deserialize({})

    assert_success(result)
    assert_payload(StructWithBooleanDefaultSetToTrue.new(tired: true), result)
  end

  def test_it_can_deserialize_with_default_value_boolean_false
    serializer = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(StructWithBooleanDefaultSetToFalse))
    result = serializer.deserialize({})

    assert_success(result)
    assert_payload(StructWithBooleanDefaultSetToFalse.new(tired: false), result)
  end

  def test_it_reports_validation_errors_on_deserialize
    result = @serializer.deserialize({name: "Max", stone_rank: RubyRank::Luminary})

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
          Typed::Validations::RequiredFieldError.new(field_name: :age),
          Typed::Validations::RequiredFieldError.new(field_name: :stone_rank)
        ]
      ),
      result
    )
  end
end
