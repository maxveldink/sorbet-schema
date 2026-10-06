# typed: true

require "test_helper"

class SerializeValueTest < Minitest::Test
  class ImmutableWithCustomSchema < T::ImmutableStruct
    extend T::Sig

    const :name, String

    sig { override.returns(Typed::Schema) }
    def self.schema
      super.add_serializer(:name, ->(value) { value.upcase })
    end
  end

  def test_when_value_is_a_hash_returns_each_value_serialized
    assert_equal({:one => "1", "two" => "2"}, SerializeValue.serialize({:one => TestEnums::EnumOne, "two" => TestEnums::EnumTwo}))
  end

  def test_when_value_is_an_array_returns_each_value_serialized
    assert_equal(["1", "2"], SerializeValue.serialize([TestEnums::EnumOne, TestEnums::EnumTwo]))
  end

  def test_when_value_is_a_struct_returns_serialized_struct
    assert_equal({name: "DC", capital: true}, SerializeValue.serialize(DC_CITY))
  end

  def test_when_value_is_an_immutable_struct_returns_serialized_struct
    assert_equal({name: "Ada", capital: false}, SerializeValue.serialize(ImmutableCity.new(name: "Ada", capital: false)))
  end

  def test_nested_immutable_structs_use_their_custom_schema
    value = ImmutableWithCustomSchema.new(name: "Ada")

    assert_equal([{name: "ADA"}, {home: {name: "ADA"}}], SerializeValue.serialize([value, {home: value}]))
  end

  def test_when_value_implements_serialize_returns_serialized_value
    assert_equal("1", SerializeValue.serialize(TestEnums::EnumOne))
  end

  def test_when_value_doesnt_serialize_returns_value
    assert_equal(1, SerializeValue.serialize(1))
  end
end
