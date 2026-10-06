# typed: true

require "test_helper"
require "msgpack"

class ImmutableStructTest < Minitest::Test
  class StructWithDefaults < T::ImmutableStruct
    const :name, String, default: "Ada"
    const :enabled, T::Boolean, default: true
    const :deleted, T::Boolean, default: false
    const :note, T.nilable(String)
  end

  class StructWithConstructor < T::ImmutableStruct
    extend T::Sig

    const :name, String

    sig { returns(T::Boolean) }
    attr_reader :constructor_called

    sig { params(name: String).void }
    def initialize(name:)
      @constructor_called = T.let(true, T::Boolean)
      super
    end
  end

  class MutableWithImmutable < T::Struct
    const :city, ImmutableCity
  end

  class UnsupportedStruct < T::InexactStruct
    const :name, String
  end

  def test_helpers_and_direct_serializers_work_for_all_scalar_formats
    sources = {
      hash: {name: "Ada", capital: false},
      json: '{"name":"Ada","capital":false}',
      csv: "name,capital\nAda,false\n",
      yml: "---\nname: Ada\ncapital: false\n",
      msgpack: MessagePack.pack({"name" => "Ada", "capital" => false})
    }

    sources.each do |format, source|
      result = ImmutableCity.deserialize_from(format, source)
      T.assert_type!(result, Typed::Result[ImmutableCity, Typed::DeserializeError])
      assert_success(result)

      city = result.payload
      T.assert_type!(city, ImmutableCity)
      assert_equal("Ada", city.name)
      refute(city.capital)
      assert(city.frozen?)

      serialized = city.serialize_to(format)
      assert_success(serialized)
      assert_equal(source, serialized.payload)

      serializer = ImmutableCity.serializer(format)
      direct_result = serializer.deserialize(source)
      assert_success(direct_result)
      assert_instance_of(ImmutableCity, direct_result.payload)
      assert(direct_result.payload.frozen?)
      assert_success(serializer.serialize(city))

      schema_result = ImmutableCity.schema.public_send(:"from_#{format}", source)
      assert_success(schema_result)
      assert_instance_of(ImmutableCity, schema_result.payload)
      assert(schema_result.payload.frozen?)
    end
  end

  def test_deserialize_from_uses_the_immutable_constructor
    result = StructWithConstructor.deserialize_from(:hash, {name: "Ada"})

    assert_success(result)
    assert(result.payload.constructor_called)
    assert(result.payload.frozen?)
  end

  def test_defaults_and_nilable_fields_keep_existing_behavior
    result = StructWithDefaults.deserialize_from(:hash, {})

    assert_success(result)
    assert_equal("Ada", result.payload.name)
    assert(result.payload.enabled)
    refute(result.payload.deleted)
    assert_nil(result.payload.note)
    assert(result.payload.frozen?)
  end

  def test_nested_immutable_structs_round_trip_in_recursive_formats
    hash = {
      "name" => "Example",
      "cities" => [{"name" => "Ada", "capital" => false}],
      "cities_by_name" => {"home" => {"name" => "Ada", "capital" => false}},
      "capital" => {"name" => "DC", "capital" => true}
    }
    sources = {json: JSON.generate(hash), yml: YAML.dump(hash), msgpack: MessagePack.pack(hash)}

    sources.each do |format, source|
      result = ImmutableCountry.deserialize_from(format, source)

      assert_success(result)
      country = result.payload
      assert(country.frozen?)
      assert(country.cities.fetch(0).frozen?)
      assert(country.cities_by_name.fetch("home").frozen?)
      assert(T.must(country.capital).frozen?)
      assert_equal("Ada", country.cities.fetch(0).name)

      serialized = country.serialize_to(format)
      assert_success(serialized)
      round_trip = ImmutableCountry.deserialize_from(format, serialized.payload)
      assert_success(round_trip)
      assert_equal(country.serialize, round_trip.payload.serialize)
    end
  end

  def test_hash_options_preserve_or_serialize_nested_immutable_values
    city = ImmutableCity.new(name: "Ada", capital: false)
    country = ImmutableCountry.new(name: "Example", cities: [city], cities_by_name: {"home" => city})

    refute(country.cities.frozen?)
    refute(country.cities_by_name.frozen?)

    result = country.serialize_to(:hash)
    assert_success(result)
    assert_same(city, result.payload[:cities].first)
    assert_same(city, result.payload[:cities_by_name].fetch("home"))

    result = country.serialize_to(:hash, options: {should_serialize_values: true})
    assert_success(result)
    assert_equal(
      {name: "Example", cities: [{name: "Ada", capital: false}], cities_by_name: {"home" => {name: "Ada", capital: false}}},
      result.payload
    )
  end

  def test_mutable_parent_can_deserialize_an_immutable_child
    result = MutableWithImmutable.deserialize_from(:hash, {city: {name: "Ada", capital: false}})
    T.assert_type!(result, Typed::Result[MutableWithImmutable, Typed::DeserializeError])

    assert_success(result)
    parent = result.payload
    T.assert_type!(parent, MutableWithImmutable)
    refute(parent.frozen?)
    assert_instance_of(ImmutableCity, parent.city)
    assert(parent.city.frozen?)
  end

  def test_immutable_parent_can_deserialize_a_mutable_child
    result = ImmutableCountry.deserialize_from(:hash, {name: "Example", mutable_city: {name: "Ada", capital: false}})

    assert_success(result)
    assert(result.payload.frozen?)
    child = T.must(result.payload.mutable_city)
    assert_instance_of(City, child)
    refute(child.frozen?)
  end

  def test_missing_required_field_keeps_the_error_contract
    result = ImmutableCity.deserialize_from(:hash, {capital: false})
    T.assert_type!(result, Typed::Result[ImmutableCity, Typed::DeserializeError])

    assert_failure(result)
    error = result.error
    T.assert_type!(error, Typed::DeserializeError)
    assert_error(Typed::Validations::RequiredFieldError.new(field_name: :name), result)
  end

  def test_invalid_nested_value_returns_a_validation_failure
    result = MutableWithImmutable.deserialize_from(:hash, {city: {capital: false}})

    assert_failure(result)
    assert_kind_of(Typed::Validations::ValidationError, result.error)
    assert_includes(result.error.message, "name is required.")
  end

  def test_malformed_json_returns_a_parse_failure
    result = ImmutableCity.deserialize_from(:json, "{")

    assert_failure(result)
    assert_kind_of(Typed::ParseError, result.error)
  end

  def test_serializing_the_wrong_supported_struct_returns_a_failure
    result = ImmutableCity.serializer(:hash).serialize(NEW_YORK_CITY)

    assert_failure(result)
    assert_error(Typed::SerializeError.new("'City' cannot be serialized to target type of 'ImmutableCity'."), result)
  end

  def test_csv_keeps_its_scalar_only_limit
    result = ImmutableCountry.new(name: "Example", cities: [ImmutableCity.new(name: "Ada", capital: false)]).serialize_to(:csv)

    assert_failure(result)
    assert_kind_of(Typed::SerializeError, result.error)
    assert_includes(result.error.message, "not scalar values")
  end

  def test_other_inexact_structs_do_not_gain_helpers
    %i[schema serializer deserialize_from].each do |method|
      refute(T::InexactStruct.respond_to?(method))
      refute(UnsupportedStruct.respond_to?(method))
    end
    refute(UnsupportedStruct.new(name: "Ada").respond_to?(:serialize_to))
    assert_raises(TypeError) { Typed::Schema.public_send(:from_struct, UnsupportedStruct) }
    refute(Typed::Coercion::StructCoercer.used_for_type?(T::Utils.coerce(UnsupportedStruct)))
  end

  def test_unknown_serializer_keeps_its_error
    error = assert_raises(ArgumentError) { ImmutableCity.serializer(:banana) }

    assert_equal("unknown serializer for banana", error.message)
  end

  def test_csv_dependency_error_is_shared
    with_gem_unavailable("csv", :CSV) do
      error = assert_raises(ArgumentError) { ImmutableCity.serializer(:csv) }
      assert_equal("csv gem is required for CSV serialization - add it to your Gemfile", error.message)
    end
  end

  def test_msgpack_dependency_error_is_shared
    with_gem_unavailable("msgpack", :MessagePack) do
      error = assert_raises(ArgumentError) { ImmutableCity.serializer(:msgpack) }
      assert_equal("msgpack gem is required for MessagePack serialization - add it to your Gemfile", error.message)
    end
  end

  def test_activerecord_dependency_error_is_shared
    with_gem_unavailable("active_record", :ActiveRecord) do
      error = assert_raises(ArgumentError) { ImmutableCity.serializer(:activerecord, options: {model_class: LocationModel}) }
      assert_equal("activerecord gem is required for ActiveRecord serialization", error.message)
    end
  end
end
