# typed: true

module T
  class Struct
    class << self
      def schema
        Typed::Schema.from_struct(self)
      end

      def serializer(type, options: {})
        # The RBI shim now promises `Typed::Serializer[T.untyped, T.untyped,
        # T.attached_class]`, which this `case` can no longer satisfy on its
        # own (each branch returns a differently-parameterized serializer).
        T.unsafe(case type
        when :hash
          Typed::HashSerializer.new(**T.unsafe({schema:, **options}))
        when :json
          Typed::JSONSerializer.new(schema:)
        when :csv
          Typed::CSVSerializer.new(schema:)
        when :yml
          Typed::YMLSerializer.new(schema:)
        when :msgpack
          Typed::MessagePackSerializer.new(schema:)
        when :activerecord
          raise ArgumentError, "activerecord gem is required for ActiveRecord serialization" unless defined?(ActiveRecord)

          Typed::ActiveRecordSerializer.new(**T.unsafe({schema:, **options}))
        else
          raise ArgumentError, "unknown serializer for #{type}"
        end)
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
