# typed: strict

module Typed
  class Serializer
    extend T::Sig
    extend T::Helpers
    abstract!

    sig { returns(Schema) }
    attr_reader :schema

    sig { params(schema: Schema).void }
    def initialize(schema:)
      @schema = schema
    end

    sig { abstract.params(source: String).returns(T::Struct) }
    def deserialize(source)
    end

    sig { abstract.params(struct: T::Struct).returns(String) }
    def serialize(struct)
    end
  end
end
