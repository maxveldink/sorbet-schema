# typed: strict

module Typed
  module Validations
    class MultipleValidationError < ValidationError
      extend T::Sig

      sig { returns(T::Array[ValidationError]) }
      attr_reader :errors

      sig { params(errors: T::Array[ValidationError]).void }
      def initialize(errors:)
        @errors = errors
        combined_message = errors.map(&:message).join(" | ")

        super("Multiple validation errors found: #{combined_message}", issues: errors.flat_map(&:issues))
      end
    end
  end
end
