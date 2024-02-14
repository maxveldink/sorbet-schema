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
      validate_required(value)
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
  end
end
