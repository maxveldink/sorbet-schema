# typed: true

require "msgpack"

class StructTest < Minitest::Test
  def test_schema_can_be_derived_from_struct
    expected_schema = Typed::Schema.new(
      fields: [
        Typed::Field.new(name: :name, type: String),
        Typed::Field.new(name: :capital, type: T::Utils.coerce(T::Boolean)),
        Typed::Field.new(name: :data, type: T::Utils.coerce(T::Hash[String, Integer]), optional: true)
      ],
      target: City
    )

    assert_equal(expected_schema, City.schema)
  end

  def test_schema_can_be_derived_from_struct_with_default
    expected_schema = Typed::Schema.new(
      fields: [
        Typed::Field.new(name: :title, type: String),
        Typed::Field.new(name: :salary, type: Money),
        Typed::Field.new(name: :start_date, type: Date, optional: true),
        Typed::Field.new(name: :needs_credential, type: T::Utils.coerce(T::Boolean), default: false, optional: true)
      ],
      target: Job
    )

    assert_equal(expected_schema, Job.schema)
  end

  def test_serializer_returns_hash_serializer_with_options
    serializer = City.serializer(:hash, options: {should_serialize_values: true})

    assert_kind_of(Typed::HashSerializer, serializer)
    assert(T.cast(serializer, Typed::HashSerializer[T.untyped]).should_serialize_values)
  end

  def test_serializer_returns_hash_serializer
    serializer = City.serializer(:hash)

    assert_kind_of(Typed::HashSerializer, serializer)
    refute(T.cast(serializer, Typed::HashSerializer[T.untyped]).should_serialize_values)
  end

  def test_serializer_returns_json_serializer
    assert_kind_of(Typed::JSONSerializer, City.serializer(:json))
  end

  def test_serializer_returns_csv_serializer
    assert_kind_of(Typed::CSVSerializer, City.serializer(:csv))
  end

  def test_serializer_returns_yml_serializer
    assert_kind_of(Typed::YMLSerializer, City.serializer(:yml))
  end

  def test_serializer_returns_msgpack_serializer
    assert_kind_of(Typed::MessagePackSerializer, City.serializer(:msgpack))
  end

  def test_serializer_raises_argument_error_when_unknown_serializer
    assert_raises(ArgumentError) { City.serializer(:banana) }
  end

  def test_serializer_raises_clear_error_when_csv_gem_unavailable
    with_gem_unavailable("csv", :CSV) do
      error = assert_raises(ArgumentError) { City.serializer(:csv) }
      assert_equal("csv gem is required for CSV serialization - add it to your Gemfile", error.message)
    end
  end

  def test_serializer_raises_clear_error_when_msgpack_gem_unavailable
    with_gem_unavailable("msgpack", :MessagePack) do
      error = assert_raises(ArgumentError) { City.serializer(:msgpack) }
      assert_equal("msgpack gem is required for MessagePack serialization - add it to your Gemfile", error.message)
    end
  end

  def test_deserialize_from_works
    result = City.deserialize_from(:hash, {name: "New York", capital: false})

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_serialize_to_works
    result = NEW_YORK_CITY.serialize_to(:json)

    assert_success(result)
    assert_payload("{\"name\":\"New York\",\"capital\":false}", result)
  end

  def test_deserialize_from_works_with_csv
    result = City.deserialize_from(:csv, "name,capital\nNew York,false\n")

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_deserialize_from_works_with_yml
    result = City.deserialize_from(:yml, "name: New York\ncapital: false\n")

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_serialize_to_works_with_csv
    result = NEW_YORK_CITY.serialize_to(:csv)

    assert_success(result)
    assert_payload("name,capital\nNew York,false\n", result)
  end

  def test_serialize_to_works_with_yml
    result = NEW_YORK_CITY.serialize_to(:yml)

    assert_success(result)
    assert_payload("---\nname: New York\ncapital: false\n", result)
  end

  def test_deserialize_from_works_with_msgpack
    result = City.deserialize_from(:msgpack, MessagePack.pack({"name" => "New York", "capital" => false}))

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_serialize_to_works_with_msgpack
    result = NEW_YORK_CITY.serialize_to(:msgpack)

    assert_success(result)
    assert_payload(MessagePack.pack({"name" => "New York", "capital" => false}), result)
  end
end
