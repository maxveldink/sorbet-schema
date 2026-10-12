# typed: strict

module Typed
  class Serializer
    extend T::Sig
    extend T::Helpers
    extend T::Generic
    abstract!

    Input = type_member
    Output = type_member
    # `T::InexactStruct` is the common Sorbet superclass of the supported
    # mutable and immutable struct classes. `Schema#target` enforces the
    # narrower runtime set because Sorbet cannot propagate their union here.
    StructT = type_member { {upper: T::InexactStruct} }
    Params = T.type_alias { T::Hash[Symbol, T.untyped] }
    DeserializeResult = T.type_alias { Result[StructValue, DeserializeError] }

    sig { returns(Schema[StructT]) }
    attr_reader :schema

    sig { returns(T::Hash[T::Types::Base, T.untyped]) }
    attr_reader :coercer_cache

    sig { params(schema: Schema[StructT]).void }
    def initialize(schema:)
      @schema = schema
      @coercer_cache = T.let({}, T::Hash[T::Types::Base, T.untyped])
    end

    sig { abstract.params(source: Input).returns(Result[StructT, DeserializeError]) }
    def deserialize(source)
    end

    sig { abstract.params(struct: StructT).returns(Result[Output, SerializeError]) }
    def serialize(struct)
    end

    private

    sig { params(creation_params: Params).returns(Result[StructT, DeserializeError]) }
    def deserialize_from_creation_params(creation_params)
      results = schema.fields.map do |field|
        result = deserialize_field(field, creation_params.fetch(key_for(field), nil))
        if result.failure?
          Failure.new(result.error.prepend_path(key_for(field).to_s))
        else
          result
        end
      end

      deserialize_from_validation_results(results)
    end

    sig { params(results: T::Array[Validations::ValidationResult]).returns(Result[StructT, DeserializeError]) }
    def deserialize_from_validation_results(results)
      Validations::ValidationResults
        .new(results:)
        .combine
        .and_then do |validated_params|
          Success.new(schema.target.new(**validated_params))
        end
    end

    # Issues here are relative to the field value; the caller adds the input key.
    sig { params(field: Field, value: Value).returns(Validations::ValidationResult) }
    def deserialize_field(field, value)
      if value.nil? && !field.default.nil?
        Success.new(Validations::ValidatedValue.new(name: field.name, value: field.default))
      elsif value.nil? || field.works_with?(value)
        field.validate(value)
      else
        coercer_instance = fetch_coercer(field.type)
        if !coercer_instance.nil?
          result = coercer_instance.coerce(type: field.type, value:)
          if result.success?
            field.validate(result.payload)
          else
            Failure.new(Validations::ValidationError.new(result.error.message, issues: result.error.issues))
          end
        elsif field.type.is_a?(T::Types::Union)
          errors = T.let([], T::Array[Coercion::CoercionError])
          validated_value = T.let(nil, T.nilable(Validations::ValidationResult))

          T.cast(field.type, T::Types::Union).types.each do |sub_type|
            # The nil branch above already handled NilClass.
            next if sub_type == T::Utils.coerce(NilClass)

            coercion_result = Coercion.coerce(type: sub_type, value: value)
            if coercion_result.success?
              validated_value = field.validate(coercion_result.payload)
              break
            else
              errors << coercion_result.error
            end
          end

          validated_value || Failure.new(Validations::ValidationError.new(
            errors.map(&:message).join(", "), issues: errors.flat_map(&:issues)
          ))
        else
          error = Coercion::CoercionNotSupportedError.new(type: field.type)
          Failure.new(Validations::ValidationError.new(error.message, issues: error.issues))
        end
      end
    end

    sig { params(struct: StructT, should_serialize_values: T::Boolean).returns(T::Hash[Symbol, T.untyped]) }
    def serialize_from_struct(struct:, should_serialize_values: false)
      hsh = schema.fields.each_with_object({}) { |field, hsh| hsh[key_for(field)] = field.serialize(struct.send(field.name)) }.compact

      if should_serialize_values
        hsh = HashTransformer.serialize_values(hsh)
      end

      hsh
    end

    # The key a field is read from and written to. Wire formats use the serialized key;
    # serializers that talk to Ruby objects (ActiveRecord) override it with the Ruby name.
    sig { params(field: Field).returns(Symbol) }
    def key_for(field)
      field.serialized_name
    end

    sig { params(type: T::Types::Base).returns(T.untyped) }
    def fetch_coercer(type)
      cached = coercer_cache[type]
      return cached if cached

      coercer_class = Coercion::CoercerRegistry.instance.select_coercer_by(type: type)
      return nil if coercer_class.nil?

      coercer_cache[type] = coercer_class.new
    end
  end
end
