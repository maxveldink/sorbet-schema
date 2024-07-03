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
    DeserializeResult = T.type_alias { Result[T::Struct, DeserializeError] }

    sig { returns(Schema) }
    attr_reader :schema

    sig { params(schema: Schema).void }
    def initialize(schema:)
      @schema = schema
    end

    sig { abstract.params(source: Input).returns(DeserializeResult) }
    def deserialize(source)
    end

    sig { abstract.params(struct: T::Struct).returns(Result[Output, SerializeError]) }
    def serialize(struct)
    end

    private

    sig { params(creation_params: Params).returns(DeserializeResult) }
    def deserialize_from_creation_params(creation_params)
      results = schema.fields.map do |field|
        value = creation_params.fetch(field.name, nil)

        if value.nil? && field.default
          Success.new(Validations::ValidatedValue.new(field.default))
        elsif value.nil? || field.works_with?(value)
          field.validate(value)
        else
          coercion_result = Coercion.coerce(type: field.type, value:)

          if coercion_result.success?
            field.validate(coercion_result.payload)
          else
            Failure.new(Validations::ValidationError.new(coercion_result.error.message))
          end
        end
      end

      Validations::ValidationResults
        .new(results:)
        .combine
        .and_then do |validated_params|
          Success.new(schema.target.new(**validated_params))
        end
    end

    sig { params(struct: T::Struct, should_serialize_values: T::Boolean).returns(T::Hash[Symbol, T.untyped]) }
    def serialize_from_struct(struct:, should_serialize_values: false)
      hsh = schema.fields.each_with_object({}) { |field, hsh| hsh[field.name] = field.serialize(struct.send(field.name)) }.compact

      HashTransformer.new(should_serialize_values: should_serialize_values).deep_symbolize_keys(hsh)
    end
  end
end
