# typed: true

class CoercionTest < Minitest::Test
  def test_coercion_coerces_structs
    result = Typed::Coercion.coerce(field: Typed::Field.new(name: :job, type: Job), value: {"title" => "Software Developer", "salary" => 90_000_00})

    assert_success(result)
    assert_payload(Job.new(title: "Software Developer", salary: 90_000_00), result)
  end

  def test_when_coercer_isnt_matched_no_op_coerces
    result = Typed::Coercion.coerce(field: Typed::Field.new(name: :testing, type: Integer), value: "testing")

    assert_success(result)
    assert_payload("testing", result)
  end
end
