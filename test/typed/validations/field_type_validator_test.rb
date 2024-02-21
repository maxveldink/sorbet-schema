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

    assert_success(result)
    assert_payload("testing", result)
  end

  def test_validate_correct_type_on_optional_field
    result = @validator.validate(field: @optional_field, value: "testing")

    assert_success(result)
    assert_payload("testing", result)
  end

  def test_validate_incorrect_type_on_required_field
    result = @validator.validate(field: @required_field, value: 1)

    assert_failure(result)
    assert_error(Typed::Validations::TypeMismatchError.new(field_name: :im_required, field_type: String, given_type: Integer), result)
  end

  def test_validate_incorrect_type_on_optional_field
    result = @validator.validate(field: @optional_field, value: 1)

    assert_failure(result)
    assert_error(Typed::Validations::TypeMismatchError.new(field_name: :im_optional, field_type: String, given_type: Integer), result)
  end

  def test_validate_nil_on_required_field
    result = @validator.validate(field: @required_field, value: nil)

    assert_failure(result)
    assert_error(Typed::Validations::RequiredFieldError.new(field_name: :im_required), result)
  end

  def test_validate_nil_on_optional_field
    result = @validator.validate(field: @optional_field, value: nil)

    assert_success(result)
    assert_nil(result.payload)
  end
end
