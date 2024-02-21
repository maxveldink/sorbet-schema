# typed: true

require "test_helper"

class MultipleValidationErrorTest < Minitest::Test
  def test_formats_error_message
    error = Typed::Validations::MultipleValidationError.new(
      errors: [
        Typed::Validations::RequiredFieldError.new(field_name: :testing),
        Typed::Validations::RequiredFieldError.new(field_name: :foobar)
      ]
    )

    assert_equal("Multiple validation errors found: testing is required. | foobar is required.", error.message)
  end
end
