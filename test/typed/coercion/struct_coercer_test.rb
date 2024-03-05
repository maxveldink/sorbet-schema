# typed: true

class StructCoercerTest < Minitest::Test
  def test_when_non_struct_field_given_returns_failure
    result = Typed::Coercion::StructCoercer.coerce(field: Typed::Field.new(name: :testing, type: Integer), value: "testing")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new, result)
  end

  def test_when_struct_can_be_coerced_returns_success
    result = Typed::Coercion::StructCoercer.coerce(field: Typed::Field.new(name: :job, type: Job), value: {"title" => "Software Developer", "salary" => 90_000_00})

    assert_success(result)
    assert_payload(Job.new(title: "Software Developer", salary: 90_000_00), result)
  end

  def test_when_struct_cannot_be_coerced_returns_failure
    result = Typed::Coercion::StructCoercer.coerce(field: Typed::Field.new(name: :job, type: Job), value: "bad")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new('"bad" provided to from_hash'), result)
  end
end
