# typed: true

class HashSerializerTest < Minitest::Test
  def setup
    @serializer = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Person))
  end

  # Serialize Tests

  def test_it_can_simple_serialize
    result = @serializer.serialize(MAX_PERSON)

    assert_success(result)
    assert_payload({name: "Max", age: 29, ruby_rank: RubyRank::Luminary}, result)
  end

  def test_it_can_serialize_with_nested_struct
    result = @serializer.serialize(ALEX_PERSON)

    assert_success(result)
    assert_payload({name: "Alex", age: 31, ruby_rank: RubyRank::Brilliant, job: Job.new(title: "Software Developer", salary: 1_000_000_00)}, result)
  end

  def test_it_can_deep_serialize
    serializer = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Person), should_serialize_values: true)

    result = serializer.serialize(ALEX_PERSON)

    assert_success(result)
    assert_payload({name: "Alex", age: 31, ruby_rank: "pretty", job: {title: "Software Developer", salary: 1_000_000_00}}, result)
  end

  def test_with_boolean_it_can_serialize
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(City)).serialize(NEW_YORK_CITY)

    assert_success(result)
    assert_payload({name: "New York", capital: false}, result)
  end

  def test_with_array_it_can_serialize
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Country)).serialize(US_COUNTRY)

    assert_success(result)
    assert_payload({name: "US", cities: [NEW_YORK_CITY, DC_CITY]}, result)
  end

  def test_with_array_it_can_deep_serialize
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Country), should_serialize_values: true).serialize(US_COUNTRY)

    assert_success(result)
    assert_payload({name: "US", cities: [{name: "New York", capital: false}, {name: "DC", capital: true}]}, result)
  end

  def test_when_struct_given_is_not_of_target_type_returns_failure
    result = @serializer.serialize(Job.new(title: "Testing", salary: 90_00))

    assert_failure(result)
    assert_error(Typed::SerializeError.new("'Job' cannot be serialized to target type of 'Person'."), result)
  end

  # Deserialize Tests

  def test_it_can_simple_deserialize
    result = @serializer.deserialize({name: "Max", age: 29, ruby_rank: RubyRank::Luminary})

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_it_can_simple_deserialize_from_string_keys
    result = @serializer.deserialize({"name" => "Max", "age" => 29, "ruby_rank" => RubyRank::Luminary})

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_with_boolean_it_can_deserialize
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(City)).deserialize({name: "New York", capital: false})

    assert_success(result)
    assert_payload(NEW_YORK_CITY, result)
  end

  def test_with_array_it_can_deserialize
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Country)).deserialize({name: "US", cities: [NEW_YORK_CITY, DC_CITY]})

    assert_success(result)
    assert_payload(US_COUNTRY, result)
  end

  def test_with_array_it_can_deep_deserialize
    result = Typed::HashSerializer.new(schema: Typed::Schema.from_struct(Country)).deserialize({name: "US", cities: [{name: "New York", capital: false}, {name: "DC", capital: true}]})

    assert_success(result)
    assert_payload(US_COUNTRY, result)
  end

  def test_it_can_deserialize_with_nested_object
    result = @serializer.deserialize({name: "Alex", age: 31, ruby_rank: "pretty", job: {title: "Software Developer", salary: 1_000_000_00}})

    assert_success(result)
    assert_payload(ALEX_PERSON, result)
  end

  def test_it_reports_validation_errors_on_deserialize
    result = @serializer.deserialize({name: "Max", ruby_rank: RubyRank::Luminary})

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
          Typed::Validations::RequiredFieldError.new(field_name: :ruby_rank)
        ]
      ),
      result
    )
  end
end
