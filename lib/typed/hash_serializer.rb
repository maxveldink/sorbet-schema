# typed: strict

module Typed
  class HashSerializer < Serializer
    InputHash = T.type_alias { T::Hash[T.any(Symbol, String), T.untyped] }
    OutputHash = T.type_alias { Params }

    Input = type_member { {fixed: InputHash} }
    Output = type_member { {fixed: OutputHash} }

    sig { params(schema: Schema, should_serialize_values: T::Boolean).void }
    def initialize(schema:, should_serialize_values: false)
      @should_serialize_values = should_serialize_values

      super(schema: schema)
    end

    sig { override.params(source: Input).returns(Result[T::Struct, DeserializeError]) }
    def deserialize(source)
      deserialize_from_creation_params(HashTransformer.new(should_serialize_values: should_serialize_values).deep_symbolize_keys(source))
    end

    sig { override.params(struct: T::Struct).returns(Output) }
    def serialize(struct)
      HashTransformer.new(should_serialize_values: should_serialize_values).deep_symbolize_keys(struct.serialize)
    end

    private

    sig { returns(T::Boolean) }
    attr_reader :should_serialize_values
  end
end
