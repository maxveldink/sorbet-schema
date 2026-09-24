# typed: true

require "test_helper"
require "msgpack"

class ArraySerializerTest < Minitest::Test
  def test_hash_serializes_and_deserializes_root_arrays
    serializer = array_serializer(:hash)

    result = serializer.serialize([MAX_PERSON, ALEX_PERSON])

    assert_success(result)
    assert_equal(2, result.payload.length)
    assert_equal("Max", result.payload.first[:name])

    deserialized = serializer.deserialize(result.payload)

    assert_success(deserialized)
    assert_payload([MAX_PERSON, ALEX_PERSON], deserialized)
  end

  def test_json_serializes_and_deserializes_root_arrays
    serializer = array_serializer(:json)

    result = serializer.serialize([MAX_PERSON, ALEX_PERSON])

    assert_success(result)
    assert_payload('[{"name":"Max","age":29,"stone_rank":"shiny"},{"name":"Alex","age":31,"stone_rank":"pretty","job":{"title":"Software Developer","salary":{"cents":9000000,"currency":"USD"},"needs_credential":false}}]', result)

    deserialized = serializer.deserialize(result.payload)

    assert_success(deserialized)
    assert_payload([MAX_PERSON, ALEX_PERSON], deserialized)
  end

  def test_yml_serializes_and_deserializes_root_arrays
    serializer = array_serializer(:yml)

    result = serializer.serialize([MAX_PERSON, ALEX_PERSON])

    assert_success(result)
    assert_payload("---\n- name: Max\n  age: 29\n  stone_rank: shiny\n- name: Alex\n  age: 31\n  stone_rank: pretty\n  job:\n    title: Software Developer\n    salary:\n      cents: 9000000\n      currency: USD\n    needs_credential: false\n", result)

    deserialized = serializer.deserialize(result.payload)

    assert_success(deserialized)
    assert_payload([MAX_PERSON, ALEX_PERSON], deserialized)
  end

  def test_yaml_format_alias_is_supported
    serializer = array_serializer(:yaml)

    assert_equal(:yml, serializer.format)
  end

  def test_msgpack_serializes_and_deserializes_root_arrays
    serializer = array_serializer(:msgpack)

    result = serializer.serialize([MAX_PERSON])

    assert_success(result)
    assert_equal([{"name" => "Max", "age" => 29, "stone_rank" => "shiny"}], MessagePack.unpack(result.payload))

    deserialized = serializer.deserialize(result.payload)

    assert_success(deserialized)
    assert_payload([MAX_PERSON], deserialized)
  end

  def test_csv_serializes_and_deserializes_every_row
    serializer = array_serializer(:csv)
    alex = Person.new(name: "Alex", age: 31, stone_rank: RubyRank::Brilliant)

    result = serializer.serialize([MAX_PERSON, alex])

    assert_success(result)
    assert_payload("name,age,stone_rank,job\nMax,29,shiny,\nAlex,31,pretty,\n", result)

    deserialized = serializer.deserialize(result.payload)

    assert_success(deserialized)
    assert_payload([MAX_PERSON, Person.new(name: "Alex", age: 31, stone_rank: RubyRank::Brilliant)], deserialized)
  end

  def test_empty_collections_round_trip_for_every_format
    {
      hash: [],
      json: "[]",
      yml: "--- []\n",
      msgpack: MessagePack.pack([]),
      csv: "name,age,stone_rank,job\n"
    }.each do |format, expected|
      serializer = array_serializer(format)

      serialized = serializer.serialize([])
      assert_success(serialized)
      assert_payload(expected, serialized)

      deserialized = serializer.deserialize(serialized.payload)
      assert_success(deserialized)
      assert_payload([], deserialized)
    end
  end

  def test_empty_csv_input_is_an_empty_collection
    result = array_serializer(:csv).deserialize("")

    assert_success(result)
    assert_payload([], result)
  end

  def test_rejects_mapping_and_scalar_document_roots
    serializer = array_serializer(:json)

    mapping_result = serializer.deserialize('{"name":"Max"}')
    scalar_result = serializer.deserialize('"Max"')

    assert_failure(mapping_result)
    assert_error(Typed::DeserializeError.new("Expected an Array at the json document root."), mapping_result)
    assert_failure(scalar_result)
    assert_error(Typed::DeserializeError.new("Expected an Array at the json document root."), scalar_result)
  end

  def test_reports_the_first_invalid_item_with_its_index
    result = array_serializer(:json).deserialize('[{"name":"Max","age":29,"stone_rank":"shiny"},{"name":"Alex","stone_rank":"pretty"}]')

    assert_failure(result)
    assert_error(Typed::DeserializeError.new("Item at index 1 could not be deserialized: age is required."), result)
  end

  def test_reports_non_mapping_items_with_their_index
    result = array_serializer(:json).deserialize('[{"name":"Max","age":29,"stone_rank":"shiny"}, "not a record"]')

    assert_failure(result)
    assert_error(Typed::DeserializeError.new("Item at index 1 must be a mapping."), result)
  end

  def test_reports_wrong_element_types_with_their_index
    result = array_serializer(:json).serialize([MAX_PERSON, DEVELOPER_JOB])

    assert_failure(result)
    assert_error(Typed::SerializeError.new("Item at index 1 could not be serialized: 'Job' cannot be serialized to target type of 'Person'."), result)
  end

  def test_preserves_nested_collections
    serializer = Typed::ArraySerializer.new(schema: Country.schema, format: :json)

    result = serializer.serialize([US_COUNTRY])

    assert_success(result)
    deserialized = serializer.deserialize(result.payload)
    assert_success(deserialized)
    assert_payload([US_COUNTRY], deserialized)
  end

  def test_csv_rejects_nested_collections_without_lossy_output
    serializer = Typed::ArraySerializer.new(schema: Country.schema, format: :csv)

    result = serializer.serialize([US_COUNTRY])

    assert_failure(result)
    assert_error(Typed::SerializeError.new("'Country' cannot be serialized to CSV because field(s) cities, national_items are not scalar values."), result)
  end

  def test_it_raises_a_clear_error_when_csv_gem_is_unavailable
    with_gem_unavailable("csv", :CSV) do
      error = assert_raises(ArgumentError) { array_serializer(:csv) }
      assert_equal("csv gem is required for CSV serialization - add it to your Gemfile", error.message)
    end
  end

  def test_it_raises_a_clear_error_when_msgpack_gem_is_unavailable
    with_gem_unavailable("msgpack", :MessagePack) do
      error = assert_raises(ArgumentError) { array_serializer(:msgpack) }
      assert_equal("msgpack gem is required for MessagePack serialization - add it to your Gemfile", error.message)
    end
  end

  private

  def array_serializer(format)
    Typed::ArraySerializer.new(schema: Person.schema, format:)
  end
end
