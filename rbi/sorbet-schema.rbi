# typed: strict

class T::Struct
  class << self
    sig { overridable.returns(Typed::Schema) }
    def schema
    end

    sig { params(type: Symbol, options: T::Hash[Symbol, T.untyped]).returns(Typed::Serializer[T.untyped, T.untyped]) }
    def serializer(type, options: {})
    end

    sig { params(serializer_type: Symbol, source: T.untyped, options: T::Hash[Symbol, T.untyped]).returns(Typed::Result[T.attached_class, Typed::DeserializeError]) }
    def deserialize_from(serializer_type, source, options: {})
    end
  end

  sig { params(serializer_type: Symbol, options: T::Hash[Symbol, T.untyped]).returns(Typed::Result[T.untyped, Typed::SerializeError]) }
  def serialize_to(serializer_type, options: {})
  end
end
