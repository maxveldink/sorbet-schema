# typed: true

class HashTransformerTest < Minitest::Test
  def setup
    # standard:disable Style/HashSyntax
    @test_hash = {
      "test" => 1,
      another: 1,
      deeper: {
        anotherhash: 2,
        "deeperagain" => {
          "value" => 3
        }
      }
    }
    # standard:enable Style/HashSyntax
    @transformer = HashTransformer.new
  end

  def test_deep_symbolize_keys_symbolizes_all_keys
    expected_hash = {
      test: 1,
      another: 1,
      deeper: {
        anotherhash: 2,
        deeperagain: {
          value: 3
        }
      }
    }

    assert_equal(expected_hash, @transformer.deep_symbolize_keys(@test_hash))
  end

  def test_deep_stringify_keys_stringifies_all_keys
    expected_hash = {
      "test" => 1,
      "another" => 1,
      "deeper" => {
        "anotherhash" => 2,
        "deeperagain" => {
          "value" => 3
        }
      }
    }

    assert_equal(expected_hash, @transformer.deep_stringify_keys(@test_hash))
  end
end
