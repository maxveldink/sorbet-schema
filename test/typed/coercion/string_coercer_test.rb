# typed: true

class StringCoercerTest < Minitest::Test
  def test_returns_success
    field = Typed::Field.new(name: :testing, type: String)

    assert_payload("1", Typed::Coercion::StringCoercer.new.coerce(field: field, value: 1))
    assert_payload("[1, 2]", Typed::Coercion::StringCoercer.new.coerce(field: field, value: [1, 2]))
  end
end
