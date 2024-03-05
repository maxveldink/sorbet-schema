# typed: strict

module Typed
  module Validations
    class ValidationResults < T::Struct
      extend T::Sig

      const :results, T::Array[ValidationResult]

      sig { returns(Result[ValidatedParams, ValidationError]) }
      def combine
        failing_results = results.select(&:failure?)

        case failing_results.length
        when 0
          Success.new(
            results.each_with_object({}) do |result, validated_params|
              validated_params[result.payload.name] = result.payload.value
            end
          )
        when 1
          Failure.new(T.must(failing_results.first).error)
        else
          Failure.new(MultipleValidationError.new(errors: failing_results.map(&:error)))
        end
      end
    end
  end
end
