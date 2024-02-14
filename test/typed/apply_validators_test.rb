# typed: true

require "test_helper"

class ApplyValidatorsTest < Minitest::Test
  def setup
    @command = Typed::ApplyValidators.new(schema: PersonSchema)
  end

  def test_when_0_failures_it_returns_success
    result = @command.call(name: "Max", age: 29)

    assert_predicate(result, :success?)
    assert_equal({name: "Max", age: 29}, result.payload)
  end

  def test_when_1_failure_it_returns_failure_and_error
    result = @command.call(name: "Max")

    assert_predicate(result, :failure?)
    assert_equal(Typed::RequiredFieldError.new(field_name: :age), result.error)
  end

  def test_when_multiple_failures_it_returns_wrapped_failures
    result = @command.call({})

    assert_predicate(result, :failure?)
    assert_equal(
      Typed::MultipleValidationError.new(errors: [
        Typed::RequiredFieldError.new(field_name: :name),
        Typed::RequiredFieldError.new(field_name: :age)
      ]),
      result.error
    )
  end
end
