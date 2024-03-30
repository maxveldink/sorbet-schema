# typed: true

class StructTest < Minitest::Test
  def test_schema_can_be_derived_from_struct
    expected_schema = Typed::Schema.new(
      fields: [
        Typed::Field.new(name: :name, type: String),
        Typed::Field.new(name: :capital, type: T::Utils.coerce(T::Boolean))
      ],
      target: City
    )

    assert_equal(expected_schema, City.schema)
  end
end
