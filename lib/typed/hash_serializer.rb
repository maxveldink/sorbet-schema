# typed: strict

module Typed
  class HashSerializer < Serializer
    InputHash = T.type_alias { T::Hash[T.any(Symbol, String), T.untyped] }
    OutputHash = T.type_alias { Params }

    Input = type_member { {fixed: InputHash} }
    Output = type_member { {fixed: OutputHash} }

    sig { override.params(source: Input).returns(Result[T::Struct, DeserializeError]) }
    def deserialize(source)
      deserialize_from_creation_params(symbolize_keys(source))
    end

    sig { override.params(struct: T::Struct).returns(Output) }
    def serialize(struct)
      symbolize_keys(struct.serialize)
    end

    private

    sig { params(hash: InputHash).returns(OutputHash) }
    def symbolize_keys(hash)
      hash.each_with_object({}) { |(k, v), h| h[k.intern] = v }
    end
  end
end
