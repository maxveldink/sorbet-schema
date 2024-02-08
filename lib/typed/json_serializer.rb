# typed: strict

module Typed
  class JSONSerializer
    extend T::Sig

    include Serializer

    sig { override.params(source: String).returns(T::Struct) }
    def deserialize(source)
      raise NotImplementedError
    end

    sig { override.params(struct: T::Struct).returns(String) }
    def serialize(struct)
      raise NotImplementedError
    end
  end
end
