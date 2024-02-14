# typed: strict

module Typed
  class MultipleValidationError < ValidationError
    extend T::Sig

    sig { params(errors: T::Array[ValidationError]).void }
    def initialize(errors:)
      combined_message = errors.map(&:message).join(" | ")

      super("Multiple validation errors found: #{combined_message}")
    end
  end
end
