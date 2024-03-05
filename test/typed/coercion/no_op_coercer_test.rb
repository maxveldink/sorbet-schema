# typed: true

class NoOpCoercerTest < Minitest::Test
  def test_always_returns_success
    result = Typed::Coercion::NoOpCoercer.coerce(field: Typed::Field.new(name: :testing, type: Integer), value: "testing")

    assert_success(result)
    assert_payload("testing", result)
  end
end
