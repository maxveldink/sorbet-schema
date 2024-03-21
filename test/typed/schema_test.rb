# typed: true

class SchemaTest < Minitest::Test
  def setup
    @schema = Typed::Schema.new(
      fields: [
        Typed::Field.new(name: :name, type: String),
        Typed::Field.new(name: :age, type: Integer),
        Typed::Field.new(name: :ruby_rank, type: RubyRank),
        Typed::Field.new(name: :job, type: Job, required: false)
      ],
      target: Person
    )
  end

  def test_from_struct_returns_schema
    assert_equal(@schema, Typed::Schema.from_struct(Person))
  end

  def test_from_hash_create_struct
    result = @schema.from_hash({name: "Max", age: 29, ruby_rank: RubyRank::Luminary})

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_from_json_creates_struct
    result = @schema.from_json('{"name": "Max", "age": 29, "ruby_rank": "shiny"}')

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
end
