# typed: strict

module Typed
  class Field < T::Struct
    extend T::Sig

    include ActsAsComparable

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

    sig { params(value: Value).returns(Validations::ValidationResult) }
    def validate(value)
      Validations::FieldTypeValidator.new.validate(field: self, value: value)
    end
  end
end
