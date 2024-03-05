# typed: true

require "date"

class CoercionTest < Minitest::Test
  def test_coercion_coerces_structs
    result = Typed::Coercion.coerce(field: Typed::Field.new(name: :job, type: Job), value: {"title" => "Software Developer", "salary" => 90_000_00})

    assert_success(result)
    assert_payload(Job.new(title: "Software Developer", salary: 90_000_00), result)
  end

  def test_coercion_coerces_strings
    result = Typed::Coercion.coerce(field: Typed::Field.new(name: :name, type: String), value: 1)

    assert_success(result)
    assert_payload("1", result)
  end

  def test_coercion_coerces_integers
    result = Typed::Coercion.coerce(field: Typed::Field.new(name: :name, type: Integer), value: "1")

    assert_success(result)
    assert_payload(1, result)
  end

  def test_coercion_coerces_floats
    result = Typed::Coercion.coerce(field: Typed::Field.new(name: :name, type: Float), value: "1.1")

    assert_success(result)
    assert_payload(1.1, result)
  end

  def test_when_coercer_isnt_matched_returns_failure
    result = Typed::Coercion.coerce(field: Typed::Field.new(name: :testing, type: Date), value: "testing")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionNotSupportedError.new, result)
  end
end
