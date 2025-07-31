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
      coercer_registry = Coercion::CoercerRegistry.instance

      results = schema.fields.map do |field|
        field_name = field.name
        field_type = field.type
        field_default = field.default

        value = creation_params.fetch(field_name, nil)
        coercer = coercer_registry.select_coercer_by(type: field_type)

        if value.nil? && !field_default.nil?
          Success.new(Validations::ValidatedValue.new(name: field_name, value: field_default))
        elsif value.nil? || field.works_with?(value)
          field.validate(value)
        elsif !coercer.nil?
          result = coercer.coerce(type: field_type, value:)
          if result.success?
            field.validate(result.payload)
          else
            Failure.new(Validations::ValidationError.new(result.error.message))
          end
        elsif field_type.class <= T::Types::Union
          errors = []
          validated_value = T.let(nil, T.nilable(Typed::Result[Typed::Validations::ValidatedValue, Typed::Validations::ValidationError]))

          T.cast(field_type, T::Types::Union).types.each do |sub_type|
            next if sub_type.raw_type.equal?(NilClass)

            coercion_result = Coercion.coerce(type: sub_type, value: value)

            if coercion_result.success?
              validated_value = field.validate(coercion_result.payload)
              break
            else
              errors << Validations::ValidationError.new(coercion_result.error.message)
            end
          end

          validated_value.nil? ? Failure.new(Validations::ValidationError.new(errors.map(&:message).join(", "))) : validated_value
        else
          Failure.new(Validations::ValidationError.new("Coercer not found for type #{field_type}."))
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

      if should_serialize_values
        hsh = HashTransformer.serialize_values(hsh)
      end

      hsh
    end
  end
end
