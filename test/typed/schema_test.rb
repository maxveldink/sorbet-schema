# typed: true

class SchemaTest < Minitest::Test
  def setup
    @schema = Typed::Schema.new(
      fields: [
        Typed::Field.new(name: :name, type: String),
        Typed::Field.new(name: :age, type: Integer),
        Typed::Field.new(name: :job, type: Job, required: false)
      ],
      target: Person
    )
    @person = Person.new(name: "Max", age: 29)
  end

  def test_from_struct_returns_schema
    assert_equal(@schema, Typed::Schema.from_struct(Person))
  end

  def test_from_hash_create_struct
    result = @schema.from_hash({name: "Max", age: 29})

    assert_success(result)
    assert_payload(@person, result)
  end

  def test_from_json_creates_struct
    result = @schema.from_json('{"name": "Max", "age": 29}')

    assert_success(result)
    assert_payload(@person, result)
  end
end
