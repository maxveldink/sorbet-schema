# typed: strict

module Typed
  class Schema < T::Struct
    extend T::Sig
    extend T::Generic
    include ActsAsComparable

    StructT = type_member { {upper: T::Struct} }

    const :fields, T::Array[Field], default: []
    # `T.all(T::Class[StructT], T.class_of(T::Struct))` rather than the bare
    # `T::Class[StructT]`: sorbet-runtime erases `T::Class[X]` to
    # `T::Class[T.untyped]` at runtime, which would silently accept a
    # non-struct `target`. Intersecting with `T.class_of(T::Struct)` restores
    # the runtime check while still narrowing statically.
    const :target, T.all(T::Class[StructT], T.class_of(T::Struct))

    sig do
      type_parameters(:S)
        .params(struct: T.all(T::Class[T.all(T::Struct, T.type_parameter(:S))], T.class_of(T::Struct)))
        .returns(Typed::Schema[T.all(T::Struct, T.type_parameter(:S))])
    end
    def self.from_struct(struct)
      Typed::Schema[T.all(T::Struct, T.type_parameter(:S))].new(
        target: struct,
        # `T::Class[X]` does not expose `X`'s singleton methods, so `.props`
        # is invisible to sorbet here even though it's always present on a
        # `T::Struct` subclass.
        fields: T.unsafe(struct).props.map do |name, properties|
          Typed::Field.new(name:, type: properties[:type_object], default: properties.fetch(:default, nil))
        end
      )
    end

    sig { params(hash: Typed::HashSerializer::InputHash).returns(Typed::Result[StructT, Typed::DeserializeError]) }
    def from_hash(hash)
      hash_serializer.deserialize(hash)
    end

    sig { params(json: String).returns(Typed::Result[StructT, Typed::DeserializeError]) }
    def from_json(json)
      json_serializer.deserialize(json)
    end

    sig { params(csv: String).returns(Typed::Result[StructT, Typed::DeserializeError]) }
    def from_csv(csv)
      csv_serializer.deserialize(csv)
    end

    sig { params(yml: String).returns(Typed::Result[StructT, Typed::DeserializeError]) }
    def from_yml(yml)
      yml_serializer.deserialize(yml)
    end

    sig { params(msgpack: String).returns(Typed::Result[StructT, Typed::DeserializeError]) }
    def from_msgpack(msgpack)
      message_pack_serializer.deserialize(msgpack)
    end

    sig { params(field_name: Symbol, serializer: Field::InlineSerializer).returns(Schema[StructT]) }
    def add_serializer(field_name, serializer)
      Schema[StructT].new(
        target: target,
        fields: fields.map do |field|
          if field.name == field_name
            Field.new(name: field.name, type: field.type, default: field.default, inline_serializer: serializer)
          else
            field
          end
        end
      )
    end

    private

    sig { returns(Typed::HashSerializer[StructT]) }
    def hash_serializer
      @hash_serializer = T.let(@hash_serializer, T.nilable(Typed::HashSerializer[StructT]))
      @hash_serializer ||= Typed::HashSerializer[StructT].new(schema: self)
    end

    sig { returns(Typed::JSONSerializer[StructT]) }
    def json_serializer
      @json_serializer = T.let(@json_serializer, T.nilable(Typed::JSONSerializer[StructT]))
      @json_serializer ||= Typed::JSONSerializer[StructT].new(schema: self)
    end

    sig { returns(Typed::CSVSerializer[StructT]) }
    def csv_serializer
      @csv_serializer = T.let(@csv_serializer, T.nilable(Typed::CSVSerializer[StructT]))
      @csv_serializer ||= Typed::CSVSerializer[StructT].new(schema: self)
    end

    sig { returns(Typed::YMLSerializer[StructT]) }
    def yml_serializer
      @yml_serializer = T.let(@yml_serializer, T.nilable(Typed::YMLSerializer[StructT]))
      @yml_serializer ||= Typed::YMLSerializer[StructT].new(schema: self)
    end

    sig { returns(Typed::MessagePackSerializer[StructT]) }
    def message_pack_serializer
      @message_pack_serializer = T.let(@message_pack_serializer, T.nilable(Typed::MessagePackSerializer[StructT]))
      @message_pack_serializer ||= Typed::MessagePackSerializer[StructT].new(schema: self)
    end
  end
end
