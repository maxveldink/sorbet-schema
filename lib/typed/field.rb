# typed: strict

module Typed
  class Field
    extend T::Sig

    InlineSerializer = T.type_alias { T.proc.params(arg0: T.untyped).returns(T.untyped) }

    sig { returns(Symbol) }
    attr_reader :name

    sig { returns(T::Types::Base) }
    attr_reader :type

    sig { returns(T::Boolean) }
    attr_reader :required

    sig { returns(T.nilable(InlineSerializer)) }
    attr_reader :inline_serializer

    sig do
      params(
        name: Symbol,
        type: T.any(T::Class[T.anything], T::Types::Base),
        required: T::Boolean,
        inline_serializer: T.nilable(InlineSerializer)
      ).void
    end
    def initialize(name:, type:, required: true, inline_serializer: nil)
      @name = name
      @type = T.let(T::Utils.coerce(type), T::Types::Base)
      @required = required
      @inline_serializer = inline_serializer
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

    sig { params(value: Value).returns(Value) }
    def serialize(value)
      if inline_serializer && value
        T.must(inline_serializer).call(value)
      else
        value
      end
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
