# typed: strict

module Typed
  class HashSerializer < Serializer
    Input = type_member { {fixed: T::Hash[T.any(Symbol, String), T.untyped]} }
    Output = type_member { {fixed: T::Hash[Symbol, T.untyped]} }

    sig { override.params(source: Input).returns(Result[T::Struct, DeserializeError]) }
    def deserialize(source)
      deserialize_from_creation_params(symbolize_keys(source))
    end

    sig { override.params(struct: T::Struct).returns(Output) }
    def serialize(struct)
      symbolize_keys(struct.serialize)
    end

    private

    sig { params(hash: T::Hash[T.any(String, Symbol), T.untyped]).returns(T::Hash[Symbol, T.untyped]) }
    def symbolize_keys(hash)
      hash.each_with_object({}) { |(k, v), h| h[k.intern] = v }
    end
  end
end
