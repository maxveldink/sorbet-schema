# typed: strict

module Typed
  module Validations
    class ValidationResults < T::Struct
      extend T::Sig

      const :results, T::Array[ValidationResult]

      sig { returns(Result[ValidatedParams, ValidationError]) }
      def combine
        failures = results.select(&:failure?)

        return Success.new(build_validated_params) if failures.empty?
        return Failure.new(T.must(failures.first).error) if failures.one?

        Failure.new(MultipleValidationError.new(errors: failures.map(&:error)))
      end

      private

      sig { returns(ValidatedParams) }
      def build_validated_params
        results.each_with_object({}) do |result, params|
          params[result.payload.name] = result.payload.value
        end
      end
    end
  end
end