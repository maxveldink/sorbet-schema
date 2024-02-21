# typed: true

class SchemaTest < Minitest::Test
  def test_field_accessor_returns_matched_field
    assert_equal(Typed::Field.new(name: :name, type: String), PersonSchema.field(name: :name))
  end

  def test_field_accessor_returns_nil_when_no_matched_fields
    assert_nil(PersonSchema.field(name: :missing))
  end
end
