# typed: strict

module Typed
  module Validations
    class FieldTypeValidator
      extend T::Sig

      include FieldValidator

      sig { override.params(field: Field, value: Value).returns(ValidationResult) }
      def validate(field:, value:)
        if field.works_with?(value)
          Success.new(ValidatedValue.new(name: field.name, value: value))
        elsif field.required? && value.nil?
          Failure.new(RequiredFieldError.new(field_name: field.name))
        elsif field.optional? && value.nil?
          Success.new(ValidatedValue.new(name: field.name, value: value))
        else
          Failure.new(TypeMismatchError.new(field_name: field.name, field_type: field.type, given_type: value.class))
        end
      end
    end
  end
end
