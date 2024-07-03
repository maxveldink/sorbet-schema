# typed: strict

module Typed
  class Field
    extend T::Sig

    InlineSerializer = T.type_alias { T.proc.params(arg0: T.untyped).returns(T.untyped) }

    sig { returns(Symbol) }
    attr_reader :name

    sig { returns(T::Types::Base) }
    attr_reader :type

    sig { returns(T.untyped) }
    attr_reader :default

    sig { returns(T::Boolean) }
    attr_reader :required

    sig { returns(T.nilable(InlineSerializer)) }
    attr_reader :inline_serializer

    sig do
      params(
        name: Symbol,
        type: T.any(T::Class[T.anything], T::Types::Base),
        optional: T::Boolean,
        default: T.untyped,
        inline_serializer: T.nilable(InlineSerializer)
      ).void
    end
    def initialize(name:, type:, optional: false, default: nil, inline_serializer: nil)
      @name = name
      # TODO: Guarentee type signature of the serializer will be valid
      @inline_serializer = inline_serializer

      coerced_type = T::Utils.coerce(type)

      if coerced_type.valid?(nil)
        @required = T.let(false, T::Boolean)
        @type = T.let(T.unsafe(coerced_type).unwrap_nilable, T::Types::Base)
      else
        @required = true
        @type = coerced_type
      end

      if optional
        @required = false
      end

      if !default.nil? && @type.valid?(default)
        @default = T.let(default, T.untyped)
        @required = false
      elsif !default.nil? && @required
        raise ArgumentError, "Given #{default} with class of #{default.class} for default, invalid with type #{@type}"
      end
    end

    sig { params(other: Field).returns(T.nilable(T::Boolean)) }
    def ==(other)
      name == other.name &&
        type == other.type &&
        required == other.required &&
        default == other.default &&
        inline_serializer == other.inline_serializer
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
