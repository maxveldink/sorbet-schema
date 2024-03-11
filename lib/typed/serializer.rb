# typed: strict

module Typed
  class Serializer
    extend T::Sig
    extend T::Helpers
    extend T::Generic
    abstract!

    Input = type_member
    Output = type_member
    Params = T.type_alias { T::Hash[Symbol, T.untyped] }
    DeserializeResult = T.type_alias { Typed::Result[T::Struct, DeserializeError] }

    sig { returns(Schema) }
    attr_reader :schema

    sig { params(schema: Schema).void }
    def initialize(schema:)
      @schema = schema
    end

    sig { abstract.params(source: Output).returns(DeserializeResult) }
    def deserialize(source)
    end

    sig { abstract.params(struct: T::Struct).returns(Output) }
    def serialize(struct)
    end

    sig { abstract.params(struct: T::Struct).returns(Output) }
    def deep_serialize(struct)
    end

    private

    sig { params(creation_params: Params).returns(DeserializeResult) }
    def deserialize_from_creation_params(creation_params)
      results = schema.fields.map do |field|
        value = creation_params[field.name]

        if value.nil?
          field.validate(value)
        elsif value.class != field.type
          coercion_result = Coercion.coerce(field: field, value: value)

          if coercion_result.success?
            field.validate(coercion_result.payload)
          else
            Failure.new(Validations::ValidationError.new(coercion_result.error.message))
          end
        else
          field.validate(value)
        end
      end

      Validations::ValidationResults
        .new(results: results)
        .combine
        .and_then do |validated_params|
          Success.new(schema.target.new(**validated_params))
        end
    end
  end
end
