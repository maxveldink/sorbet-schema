# typed: strict

module Typed
  class RequiredFieldValidator
    extend T::Sig

    include FieldValidator

    sig { override.params(field: Field, value: Value).returns(ValidationResult) }
    def validate(field:, value:)
      if field.required? && value.nil?
        Failure.new(RequiredFieldError.new(field_name: field.name))
      else
        Success.new(value)
      end
    end
  end
end
