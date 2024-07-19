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

      sig { params(type: Symbol).returns(Typed::Serializer[T.untyped, T.untyped]) }
      def serializer(type)
        case type
        when :deeply_nested_hash
          Typed::HashSerializer.new(schema:, should_serialize_values: true)
        when :hash
          Typed::HashSerializer.new(schema:)
        when :json
          Typed::JSONSerializer.new(schema:)
        else
          raise ArgumentError, "unknown serializer for #{type}"
        end
      end

      sig { params(serializer_type: Symbol, source: T.untyped).returns(Typed::Serializer::DeserializeResult) }
      def deserialize_from(serializer_type, source)
        serializer(serializer_type).deserialize(source)
      end
    end

    sig { params(serializer_type: Symbol).returns(Typed::Result[T.untyped, Typed::SerializeError]) }
    def serialize_to(serializer_type)
      self.class.serializer(serializer_type).serialize(self)
    end
  end
end
