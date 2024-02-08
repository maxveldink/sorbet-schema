# typed: strict

module Typed
  module Serializer
    extend T::Sig
    extend T::Helpers
    interface!

    sig { abstract.params(source: String).returns(T::Struct) }
    def deserialize(source)
    end

    sig { abstract.params(struct: T::Struct).returns(String) }
    def serialize(struct)
    end
  end
end
