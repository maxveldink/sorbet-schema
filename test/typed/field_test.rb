# typed: true

require "test_helper"

class FieldTest < Minitest::Test
  def setup
    @required_field = Typed::Field.new(name: :im_required, type: String)
    @optional_field = Typed::Field.new(name: :im_optional, type: String, required: false)
  end

  def test_required_and_optional_helpers_work_when_required
    assert_predicate(@required_field, :required?)
    refute_predicate(@required_field, :optional?)
  end

  def test_required_and_optional_helpers_work_when_optional
    assert_predicate(@optional_field, :optional?)
    refute_predicate(@optional_field, :required?)
  end

  def test_validate_nil_value_for_required_field
    result = @required_field.validate(nil)

    assert_predicate(result, :failure?)
    assert_equal(Typed::RequiredFieldError.new(field_name: :im_required), result.error)
  end

  def test_validate_present_value_for_required_field
    result = @required_field.validate("testing")

    assert_predicate(result, :success?)
    assert_equal("testing", result.payload)
  end

  def test_validate_nil_value_for_optional_field
    result = @optional_field.validate(nil)

    assert_predicate(result, :success?)
    assert_nil(result.payload)
  end

  def test_validate_present_value_for_optional_field
    result = @optional_field.validate("testing")

    assert_predicate(result, :success?)
    assert_equal("testing", result.payload)
  end
end
