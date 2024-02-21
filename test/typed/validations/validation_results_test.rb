# typed: true

require "test_helper"

class ValidationResultsTest < Minitest::Test
  def setup
    @success = Typed::Success.new("Testing")
    @error = Typed::Validations::RequiredFieldError.new(field_name: :bad)
    @failure = Typed::Failure.new(@error)
  end

  def test_when_0_failures_combine_returns_success
    result = Typed::Validations::ValidationResults.new(results: [@success]).combine

    assert_success(result)
    assert_nil(result.payload)
  end

  def test_when_1_failure_it_returns_failure_and_error
    result = Typed::Validations::ValidationResults.new(results: [@success, @failure]).combine

    assert_failure(result)
    assert_error(@error, result)
  end

  def test_when_multiple_failures_it_returns_wrapped_failures
    result = Typed::Validations::ValidationResults.new(results: [@failure, @success, @failure]).combine

    assert_failure(result)
    assert_error(
      Typed::Validations::MultipleValidationError.new(errors: [@error, @error]),
      result
    )
  end
end
