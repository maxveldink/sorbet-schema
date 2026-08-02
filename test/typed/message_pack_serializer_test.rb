# typed: true

require "test_helper"

class MessagePackSerializerTest < Minitest::Test
  def setup
    @serializer = Typed::MessagePackSerializer.new(schema: Typed::Schema.from_struct(Person))
  end

  # Serialize Tests

  def test_it_can_simple_serialize
    result = @serializer.serialize(MAX_PERSON)

    assert_success(result)
    assert_payload(MessagePack.pack({"name" => "Max", "age" => 29, "stone_rank" => "shiny"}), result)
  end

  def test_it_can_serialize_with_nested_struct
    result = @serializer.serialize(ALEX_PERSON)

    assert_success(result)
    assert_payload(
      MessagePack.pack({
        "name" => "Alex",
        "age" => 31,
        "stone_rank" => "pretty",
        "job" => {"title" => "Software Developer", "salary" => {"cents" => 9_000_000, "currency" => "USD"}, "needs_credential" => false}
      }),
      result
    )
  end

  def test_with_boolean_it_can_serialize
    result = Typed::MessagePackSerializer.new(schema: Typed::Schema.from_struct(City)).serialize(NEW_YORK_CITY)

    assert_success(result)
    assert_payload(MessagePack.pack({"name" => "New York", "capital" => false}), result)
  end

  def test_with_array_it_can_serialize
    result = Typed::MessagePackSerializer.new(schema: Typed::Schema.from_struct(Country)).serialize(US_COUNTRY)

    assert_success(result)
    assert_payload(
      MessagePack.pack({
        "name" => "US",
        "cities" => [{"name" => "New York", "capital" => false}, {"name" => "DC", "capital" => true}],
        "national_items" => {"bird" => "bald eagle", "anthem" => "The Star-Spangled Banner"}
      }),
      result
    )
  end

  def test_will_use_inline_serializers
    result = Typed::MessagePackSerializer.new(schema: JOB_SCHEMA_WITH_INLINE_SERIALIZER).serialize(DEVELOPER_JOB_WITH_START_DATE)

    assert_success(result)
    assert_payload(
      MessagePack.pack({"title" => "Software Developer", "salary" => {"cents" => 9_000_000, "currency" => "USD"}, "start_date" => "061 March"}),
      result
    )
  end

  def test_when_struct_given_is_not_of_target_type_returns_failure
    result = @serializer.serialize(DEVELOPER_JOB)

    assert_failure(result)
    assert_error(Typed::SerializeError.new("'Job' cannot be serialized to target type of 'Person'."), result)
  end

  # Deserialize Tests

  def test_it_can_simple_deserialize
    result = @serializer.deserialize(MessagePack.pack({"name" => "Max", "age" => 29, "stone_rank" => "shiny"}))

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_with_boolean_it_can_deserialize
    result = Typed::MessagePackSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize(MessagePack.pack({"name" => "New York", "capital" => false}))

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_with_boolean_string_true_it_can_deserialize
    result = Typed::MessagePackSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize(MessagePack.pack({"name" => "DC", "capital" => "true"}))

    assert_success(result)
    assert_payload(DC_CITY, result)
  end

  def test_with_array_it_can_deep_deserialize
    result = Typed::MessagePackSerializer.new(schema: Typed::Schema.from_struct(Country)).deserialize(
      MessagePack.pack({
        "name" => "US",
        "cities" => [{"name" => "New York", "capital" => false}, {"name" => "DC", "capital" => true}],
        "national_items" => {"bird" => "bald eagle", "anthem" => "The Star-Spangled Banner"}
      })
    )

    assert_success(result)
    assert_payload(US_COUNTRY, result)
  end

  def test_it_can_deserialize_with_nested_object
    result = @serializer.deserialize(
      MessagePack.pack({
        "name" => "Alex",
        "age" => 31,
        "stone_rank" => "pretty",
        "job" => {"title" => "Software Developer", "salary" => {"cents" => 9_000_000, "currency" => "USD"}}
      })
    )

    assert_success(result)
    assert_payload(ALEX_PERSON, result)
  end

  def test_it_reports_on_parse_errors_on_deserialize
    result = @serializer.deserialize("\xFF\xFF\xFF".b)

    assert_failure(result)
    assert_error(Typed::ParseError.new(format: :msgpack), result)
  end

  def test_it_reports_a_parse_error_when_msgpack_is_not_a_map
    result = @serializer.deserialize(MessagePack.pack([1, 2, 3]))

    assert_failure(result)
    assert_error(Typed::ParseError.new(format: :msgpack), result)
  end

  def test_it_reports_validation_errors_on_deserialize
    result = @serializer.deserialize(MessagePack.pack({"name" => "Max", "stone_rank" => "shiny"}))

    assert_failure(result)
    assert_error(Typed::Validations::RequiredFieldError.new(field_name: :age), result)
  end

  def test_it_reports_multiple_validation_errors_on_deserialize
    result = @serializer.deserialize(MessagePack.pack({}))

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
