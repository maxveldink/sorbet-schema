# typed: true

module T
  module StructClassMethods
    def schema
      T.bind(self, Typed::StructClass)
      Typed::Schema.from_struct(self)
    end

    def serializer(type, options: {})
      T.bind(self, Typed::StructClass)
      # The RBI shim promises a serializer parameterized by the attached class,
      # while this case has different serializer subclasses on each branch.
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

  module StructInstanceMethods
    def serialize_to(serializer_type, options: {})
      T.bind(self, Typed::StructValue)
      T.unsafe(self.class.serializer(serializer_type, options:)).serialize(self)
    end
  end

  class Struct
    extend StructClassMethods
    include StructInstanceMethods
  end

  class ImmutableStruct
    extend StructClassMethods
    include StructInstanceMethods
  end
end
