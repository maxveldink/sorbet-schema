# typed: true

require "test_helper"

class HashTransformerTest < Minitest::Test
  def setup
    @test_hash = {
      "test" => TestEnums::EnumOne,
      :another => 1,
      :deeper => {
        :anotherhash => 2,
        "deeperagain" => {
          "value" => TestEnums::EnumThree,
          "boolean" => false,
          "date" => Date.new(1776, 7, 4),
          "array" => [1, TestEnums::EnumOne, {"verydeep" => 1}]
        }
      }
    }
  end

  def test_symbolize_keys_symbolizes_first_level_keys
    expected_hash = {
      test: TestEnums::EnumOne,
      another: 1,
      deeper: {
        :anotherhash => 2,
        "deeperagain" => {
          "value" => TestEnums::EnumThree,
          "boolean" => false,
          "date" => Date.new(1776, 7, 4),
          "array" => [1, TestEnums::EnumOne, {"verydeep" => 1}]
        }
      }
    }

    assert_equal(expected_hash, HashTransformer.symbolize_keys(@test_hash))
  end

  def test_serialize_values_serializes_values
    expected_hash = {
      "test" => "1",
      :another => 1,
      :deeper => {
        :anotherhash => 2,
        "deeperagain" => {
          "value" => "3",
          "boolean" => false,
          "date" => Date.new(1776, 7, 4),
          "array" => [1, "1", {"verydeep" => 1}]
        }
      }
    }

    assert_equal(expected_hash, HashTransformer.serialize_values(@test_hash))
  end
end
