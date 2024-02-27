# typed: true

class StructExtTest < Minitest::Test
  def test_create_schema_is_available
    assert_equal(PersonSchema, Person.create_schema)
  end
end
