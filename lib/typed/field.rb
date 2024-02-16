# typed: strict

module Typed
  class Field < T::Struct
    extend T::Sig

    const :name, Symbol
    const :type, T::Class[T.anything]
    const :required, T::Boolean, default: true

    ValidationResult = T.type_alias { Result[T.untyped, ValidationError] }

    sig { returns(T::Boolean) }
    def required?
      required
    end

    sig { returns(T::Boolean) }
    def optional?
      !required
    end

    sig { params(value: T.untyped).returns(ValidationResult) }
    def validate(value)
      validate_required(value).and_then { |value| validate_type(value) }
    end

    private

    sig { params(value: T.untyped).returns(ValidationResult) }
    def validate_required(value)
      if required? && value.nil?
        Failure.new(RequiredFieldError.new(field_name: name))
      else
        Success.new(value)
      end
    end

    sig { params(value: T.untyped).returns(ValidationResult) }
    def validate_type(value)
      if type == value.class
        Success.new(value)
      elsif optional? && value.nil?
        Success.new(value)
      else
        Failure.new(TypeMismatchError.new(field_name: name, field_type: type, given_type: value.class))
      end
    end
  end
end
