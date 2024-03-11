# typed: strict

module Typed
  class HashSerializer < Serializer
    InputHash = T.type_alias { T::Hash[T.any(Symbol, String), T.untyped] }
    OutputHash = T.type_alias { Params }

    Input = type_member { {fixed: InputHash} }
    Output = type_member { {fixed: OutputHash} }

    sig { override.params(source: Input).returns(Result[T::Struct, DeserializeError]) }
    def deserialize(source)
      deserialize_from_creation_params(HashTransformer.new.deep_symbolize_keys(source))
    end

    sig { override.params(struct: T::Struct).returns(Output) }
    def serialize(struct)
      HashTransformer.new.deep_symbolize_keys(struct.serialize)
    end

    sig { override.params(struct: T::Struct).returns(Output) }
    def deep_serialize(struct)
      HashTransformer.new.deep_symbolize_keys_serialize_values(struct.serialize)
    end
  end
end
