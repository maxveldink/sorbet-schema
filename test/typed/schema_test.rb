# typed: true

require "msgpack"

class SchemaTest < Minitest::Test
  def setup
    @schema = Typed::Schema.new(
      fields: [
        Typed::Field.new(name: :name, type: String),
        Typed::Field.new(name: :age, type: Integer),
        Typed::Field.new(name: :stone_rank, type: T::Utils.coerce(T.any(RubyRank, DiamondRank))),
        Typed::Field.new(name: :job, type: Job, optional: true)
      ],
      target: Person
    )
  end

  def test_from_struct_returns_schema
    assert_equal(@schema, Typed::Schema.from_struct(Person))
  end

  def test_from_hash_create_struct
    result = @schema.from_hash({name: "Max", age: 29, stone_rank: RubyRank::Luminary})

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_from_json_creates_struct
    result = @schema.from_json('{"name": "Max", "age": 29, "stone_rank": "shiny"}')

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_from_csv_creates_struct
    result = @schema.from_csv("name,age,stone_rank\nMax,29,shiny\n")

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_from_yml_creates_struct
    result = @schema.from_yml("name: Max\nage: 29\nstone_rank: shiny\n")

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_from_msgpack_creates_struct
    result = @schema.from_msgpack(MessagePack.pack({"name" => "Max", "age" => 29, "stone_rank" => "shiny"}))

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_add_serializer_when_no_matching_field_returns_same_schema
    schema = @schema.add_serializer(:not_here, ->(value) { value + "a" })

    assert_equal(@schema, schema)
  end

  def test_add_serializer_when_matching_field_returns_schema_with_serializer
    schema = @schema.add_serializer(:name, ->(value) { value + "a" })

    refute_equal(@schema, schema)
  end

  def test_add_serializer_on_optional_field_keeps_field_optional
    schema = @schema.add_serializer(:job, ->(value) { value })

    result = schema.from_hash({name: "Max", age: 29, stone_rank: RubyRank::Luminary})

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end
end
