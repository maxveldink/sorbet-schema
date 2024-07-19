# typed: strict

module Typed
  class HashSerializer < Serializer
    InputHash = T.type_alias { T::Hash[T.any(Symbol, String), T.untyped] }
    Input = type_member { {fixed: InputHash} }
    Output = type_member { {fixed: Params} }

    sig { returns(T::Boolean) }
    attr_reader :should_serialize_values

    sig { params(schema: Schema, should_serialize_values: T::Boolean).void }
    def initialize(schema:, should_serialize_values: false)
      @should_serialize_values = should_serialize_values

      super(schema: schema)
    end

    sig { override.params(source: Input).returns(Result[T::Struct, DeserializeError]) }
    def deserialize(source)
      deserialize_from_creation_params(HashTransformer.symbolize_keys(source))
    end

    sig { override.params(struct: T::Struct).returns(Result[Output, SerializeError]) }
    def serialize(struct)
      return Failure.new(SerializeError.new("'#{struct.class}' cannot be serialized to target type of '#{schema.target}'.")) if struct.class != schema.target

      Success.new(serialize_from_struct(struct:, should_serialize_values:))
    end
  end
end
