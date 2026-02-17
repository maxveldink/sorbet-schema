# typed: strict

module Typed
  module Validations
    class MultipleValidationError < ValidationError
      extend T::Sig

      sig { params(errors: T::Array[ValidationError]).void }
      def initialize(errors:)
        super("Multiple validation errors found: #{errors.map(&:message).join(" | ")}")
      end
    end
  end
end