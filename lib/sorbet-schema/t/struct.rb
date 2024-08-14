# typed: true

module T
  class Struct
    class << self
      def schema
        Typed::Schema.from_struct(self)
      end

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

      def deserialize_from(serializer_type, source, options: {})
        T.unsafe(serializer(serializer_type, options:).deserialize(source))
      end
    end

    def serialize_to(serializer_type, options: {})
      self.class.serializer(serializer_type, options:).serialize(self)
    end
  end
end
