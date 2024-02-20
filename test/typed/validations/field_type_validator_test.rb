# typed: true

require "test_helper"

class FieldTypeValidatorTest < Minitest::Test
  def setup
    @validator = Typed::Validations::FieldTypeValidator.new
    @required_field = Typed::Field.new(name: :im_required, type: String)
    @optional_field = Typed::Field.new(name: :im_optional, type: String, required: false)
  end

  def test_validate_correct_type_on_required_field
    result = @validator.validate(field: @required_field, value: "testing")

    assert_predicate(result, :success?)
    assert_equal("testing", result.payload)
  end

  def test_validate_correct_type_on_optional_field
    result = @validator.validate(field: @optional_field, value: "testing")

    assert_predicate(result, :success?)
    assert_equal("testing", result.payload)
  end

  def test_validate_incorrect_type_on_required_field
    result = @validator.validate(field: @required_field, value: 1)

    assert_predicate(result, :failure?)
    assert_equal(Typed::Validations::TypeMismatchError.new(field_name: :im_required, field_type: String, given_type: Integer), result.error)
  end

  def test_validate_incorrect_type_on_optional_field
    result = @validator.validate(field: @optional_field, value: 1)

    assert_predicate(result, :failure?)
    assert_equal(Typed::Validations::TypeMismatchError.new(field_name: :im_optional, field_type: String, given_type: Integer), result.error)
  end

  def test_validate_nil_on_required_field
    result = @validator.validate(field: @required_field, value: nil)

    assert_predicate(result, :failure?)
    assert_equal(Typed::Validations::RequiredFieldError.new(field_name: :im_required), result.error)
  end

  def test_validate_nil_on_optional_field
    result = @validator.validate(field: @optional_field, value: nil)

    assert_predicate(result, :success?)
    assert_nil(result.payload)
  end
end
