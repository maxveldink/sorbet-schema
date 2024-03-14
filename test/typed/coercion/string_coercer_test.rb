# typed: true

class StringCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::StringCoercer.new
  end

  def test_used_for_type_works
    assert(@coercer.used_for_type?(String))
    refute(@coercer.used_for_type?(Integer))
  end

  def test_returns_success
    assert_payload("1", @coercer.coerce(type: String, value: 1))
    assert_payload("[1, 2]", @coercer.coerce(type: String, value: [1, 2]))
  end
end
