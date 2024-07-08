# typed: true

require "test_helper"

class SerializeValueTest < Minitest::Test
  def test_when_value_is_a_hash_returns_each_value_serialized
    assert_equal({:one => "1", "two" => "2"}, SerializeValue.serialize({:one => TestEnums::EnumOne, "two" => TestEnums::EnumTwo}))
  end

  def test_when_value_is_an_array_returns_each_value_serialized
    assert_equal(["1", "2"], SerializeValue.serialize([TestEnums::EnumOne, TestEnums::EnumTwo]))
  end

  def test_when_value_is_a_struct_returns_serialized_struct
    assert_equal({name: "DC", capital: true}, SerializeValue.serialize(DC_CITY))
  end

  def test_when_value_implements_serialize_returns_serialized_value
    assert_equal("1", SerializeValue.serialize(TestEnums::EnumOne))
  end

  def test_when_value_doesnt_serialize_returns_value
    assert_equal(1, SerializeValue.serialize(1))
  end
end
