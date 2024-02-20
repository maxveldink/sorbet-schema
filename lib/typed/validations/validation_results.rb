# typed: strict

module Typed
  module Validations
    class ValidationResults < T::Struct
      extend T::Sig

      const :results, T::Array[ValidationResult]

      sig { returns(ValidationResult) }
      def combine
        failing_results = results.select(&:failure?)

        case failing_results.length
        when 0
          Success.blank
        when 1
          Failure.new(T.must(failing_results.first).error)
        else
          Failure.new(MultipleValidationError.new(errors: failing_results.map(&:error)))
        end
      end
    end
  end
end
