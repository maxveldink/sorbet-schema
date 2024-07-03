# typed: true

class StructTest < Minitest::Test
  def test_schema_can_be_derived_from_struct
    expected_schema = Typed::Schema.new(
      fields: [
        Typed::Field.new(name: :name, type: String),
        Typed::Field.new(name: :capital, type: T::Utils.coerce(T::Boolean))
      ],
      target: City
    )

    assert_equal(expected_schema, City.schema)
  end

  def test_schema_can_be_derived_from_struct_with_default
    expected_schema = Typed::Schema.new(
      fields: [
        Typed::Field.new(name: :title, type: String),
        Typed::Field.new(name: :salary, type: Integer),
        Typed::Field.new(name: :start_date, type: Date, optional: true),
        Typed::Field.new(name: :needs_credential, type: T::Utils.coerce(T::Boolean), default: false, optional: true)
      ],
      target: Job
    )

    assert_equal(expected_schema, Job.schema)
  end

  def test_serializer_returns_hash_serializer
    assert_kind_of(Typed::HashSerializer, City.serializer(:hash))
  end

  def test_serializer_returns_json_serializer
    assert_kind_of(Typed::JSONSerializer, City.serializer(:json))
  end

  def test_serializer_raises_argument_error_when_unknown_serializer
    assert_raises(ArgumentError) { City.serializer(:banana) }
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
end
