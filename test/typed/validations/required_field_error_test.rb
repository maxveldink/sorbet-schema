# typed: true

require "test_helper"

class RequiredFieldErrorTest < Minitest::Test
  def test_formats_error_message
    assert_equal("testing is required.", Typed::Validations::RequiredFieldError.new(field_name: :testing).message)
  end
end
