# typed: strict

module Typed
  class Field < T::Struct
    extend T::Sig

    const :name, Symbol
    const :type, T::Class[T.anything]
    const :required, T::Boolean, default: true

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
      ApplyValidators.new(validators)
      results = default_validators.map do |validator|
        validator.validate(field: self, value:)
      end
    end

    private

    sig { returns(T::Array[FieldValidator]) }
    def default_validators
      [RequiredFieldValidator.new, TypeFieldValidator.new]
    end
  end
end
