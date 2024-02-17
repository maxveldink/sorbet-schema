# typed: strict

module Typed
  class TypeFieldValidator
    extend T::Sig

    include FieldValidator

    sig { override.params(field: Field, value: Value).returns(ValidationResult) }
    def validate(field:, value:)
      if field.type == value.class
        Success.new(value)
      elsif field.optional? && value.nil?
        Success.new(value)
      else
        Failure.new(TypeMismatchError.new(field_name: field.name, field_type: field.type, given_type: value.class))
      end
    end
  end
end
