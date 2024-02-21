# typed: true

require "test_helper"

class TypeMismatchErrorTest < Minitest::Test
  def test_formats_error_message
    assert_equal("Invalid type given to im_required. Expected String, got Integer.", Typed::Validations::TypeMismatchError.new(field_name: :im_required, field_type: String, given_type: Integer).message)
  end
end
