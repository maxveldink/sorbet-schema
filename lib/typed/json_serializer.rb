# typed: strict

require "json"

module Typed
  class JSONSerializer < Serializer
    extend T::Sig

    sig { override.params(source: String).returns(T::Struct) }
    def deserialize(source)
      schema.target.from_hash(JSON.parse(source))
    end

    sig { override.params(struct: T::Struct).returns(String) }
    def serialize(struct)
      JSON.generate(struct.serialize)
    end
  end
end
