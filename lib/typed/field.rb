# typed: strict

module Typed
  class Field < T::Struct
    extend T::Sig

    include ActsAsComparable

    Type = T.type_alias { T.any(T::Class[T.anything], T::Types::Base) }

    const :name, Symbol
    const :type, Type
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

    sig { params(value: Value).returns(T::Boolean) }
    def works_with?(value)
      value.class == type || T.cast(type, T::Types::Base).recursively_valid?(value) # standard:disable Style/ClassEqualityComparison
    rescue TypeError
      false
    end
  end
end
