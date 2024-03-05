# typed: true

require "test_helper"

class ValidationResultsTest < Minitest::Test
  def setup
    @success1 = Typed::Success.new(Typed::Validations::ValidatedValue.new(name: :test, value: "testing"))
    @success2 = Typed::Success.new(Typed::Validations::ValidatedValue.new(name: :test_again, value: 1))
    @error = Typed::Validations::RequiredFieldError.new(field_name: :bad)
    @failure = Typed::Failure.new(@error)
  end

  def test_when_0_failures_combine_returns_success
    result = Typed::Validations::ValidationResults.new(results: [@success1, @success2]).combine

    assert_success(result)
    assert_payload({test: "testing", test_again: 1}, result)
  end

  def test_when_1_failure_it_returns_failure_and_error
    result = Typed::Validations::ValidationResults.new(results: [@success1, @failure]).combine

    assert_failure(result)
    assert_error(@error, result)
  end

  def test_when_multiple_failures_it_returns_wrapped_failures
    result = Typed::Validations::ValidationResults.new(results: [@failure, @success1, @failure]).combine

    assert_failure(result)
    assert_error(
      Typed::Validations::MultipleValidationError.new(errors: [@error, @error]),
      result
    )
  end
end
