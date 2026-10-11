# typed: true

require "test_helper"
require "msgpack"

class ImmutableStructTest < Minitest::Test
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

  def test_helpers_round_trip_all_scalar_formats
    sources = {
      hash: {name: "Ada", capital: false},
      json: '{"name":"Ada","capital":false}',
      csv: "name,capital\nAda,false\n",
      yml: "---\nname: Ada\ncapital: false\n",
      msgpack: MessagePack.pack({"name" => "Ada", "capital" => false})
    }

    sources.each do |format, source|
      result = ImmutableCity.deserialize_from(format, source)

      assert_success(result)
      city = result.payload
      assert_instance_of(ImmutableCity, city)
      assert(city.frozen?)
      assert_equal("Ada", city.name)
      refute(city.capital)
      serialized = city.serialize_to(format)
      assert_success(serialized)
      assert_equal(source, serialized.payload)
    end
  end

  def test_uses_the_immutable_constructor
    result = StructWithConstructor.deserialize_from(:hash, {name: "Ada"})

    assert_success(result)
    assert(result.payload.constructor_called)
    assert(result.payload.frozen?)
  end

  def test_recursively_coerces_nested_immutable_values
    result = ImmutableCountry.deserialize_from(
      :hash,
      {
        name: "Example",
        cities: [{name: "Ada", capital: false}],
        cities_by_name: {"home" => {name: "DC", capital: true}},
        capital: {name: "DC", capital: true},
        mutable_city: {name: "Miami", capital: false}
      }
    )

    assert_success(result)
    country = result.payload
    assert(country.frozen?)
    assert(country.cities.fetch(0).frozen?)
    assert(country.cities_by_name.fetch("home").frozen?)
    assert(T.must(country.capital).frozen?)
    refute(T.must(country.mutable_city).frozen?)
  end

  def test_mutable_structs_can_deserialize_immutable_children
    result = MutableWithImmutable.deserialize_from(:hash, {city: {name: "Ada", capital: false}})

    assert_success(result)
    refute(result.payload.frozen?)
    assert(result.payload.city.frozen?)
  end

  def test_unsupported_inexact_structs_do_not_gain_helpers
    %i[schema serializer deserialize_from].each do |method|
      refute(T::InexactStruct.respond_to?(method))
      refute(UnsupportedStruct.respond_to?(method))
    end
    refute(UnsupportedStruct.new(name: "Ada").respond_to?(:serialize_to))
    assert_raises(TypeError) { Typed::Schema.from_struct(T.unsafe(UnsupportedStruct)) }
    refute(Typed::Coercion::StructCoercer.used_for_type?(T::Utils.coerce(UnsupportedStruct)))
  end
end
