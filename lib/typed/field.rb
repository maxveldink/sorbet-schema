# typed: strict

module Typed
  class Field
    extend T::Sig

    sig { returns(Symbol) }
    attr_reader :name

    sig { returns(T::Types::Base) }
    attr_reader :type

    sig { returns(T::Boolean) }
    attr_reader :required

    sig { params(name: Symbol, type: T.any(T::Class[T.anything], T::Types::Base), required: T::Boolean).void }
    def initialize(name:, type:, required: true)
      @name = name
      @type = T.let(T::Utils.coerce(type), T::Types::Base)
      @required = required
    end

    sig { params(other: Field).returns(T.nilable(T::Boolean)) }
    def ==(other)
      name == other.name &&
        type == other.type &&
        required == other.required
    end

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
      type.recursively_valid?(value)
    end
  end
end
