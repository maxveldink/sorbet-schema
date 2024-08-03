# typed: strict

module T
  class Struct
    extend T::Sig

    class << self
      extend T::Sig

      sig { overridable.returns(Typed::Schema) }
      def schema
        Typed::Schema.from_struct(self)
      end

      sig { params(type: Symbol, options: T::Hash[Symbol, T.untyped]).returns(Typed::Serializer[T.untyped, T.untyped]) }
      def serializer(type, options: {})
        case type
        when :hash
          Typed::HashSerializer.new(**T.unsafe({schema:, **options}))
        when :json
          Typed::JSONSerializer.new(schema:)
        else
          raise ArgumentError, "unknown serializer for #{type}"
        end
      end

      sig { params(serializer_type: Symbol, source: T.untyped, options: T::Hash[Symbol, T.untyped]).returns(Typed::Serializer::DeserializeResult) }
      def deserialize_from(serializer_type, source, options: {})
        serializer(serializer_type, options:).deserialize(source)
      end
    end

    sig { params(serializer_type: Symbol, options: T::Hash[Symbol, T.untyped]).returns(Typed::Result[T.untyped, Typed::SerializeError]) }
    def serialize_to(serializer_type, options: {})
      self.class.serializer(serializer_type, options:).serialize(self)
    end
  end
end
