# typed: true

class SchemaTest < Minitest::Test
  def test_from_struct_returns_schema
    expected_schema = Typed::Schema.new(
      fields: [
        Typed::Field.new(name: :name, type: String),
        Typed::Field.new(name: :age, type: Integer),
        Typed::Field.new(name: :job, type: Job, required: false)
      ],
      target: Person
    )

    assert_equal(expected_schema, Typed::Schema.from_struct(Person))
  end
end
