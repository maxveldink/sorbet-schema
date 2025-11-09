# typed: strict

module Typed
  class Schema < T::Struct
    extend T::Sig
    include ActsAsComparable

    const :fields, T::Array[Field], default: []
    const :target, T.class_of(T::Struct)

    sig { params(struct: T.class_of(T::Struct)).returns(Typed::Schema) }
    def self.from_struct(struct)
      Typed::Schema.new(
        target: struct,
        fields: struct.props.map do |name, properties|
          Typed::Field.new(name:, type: properties[:type_object], default: properties.fetch(:default, nil))
        end
      )
    end

    sig { params(hash: Typed::HashSerializer::InputHash).returns(Typed::Serializer::DeserializeResult) }
    def from_hash(hash)
      hash_serializer.deserialize(hash)
    end

    sig { params(json: String).returns(Typed::Serializer::DeserializeResult) }
    def from_json(json)
      json_serializer.deserialize(json)
    end

    sig { params(field_name: Symbol, serializer: Field::InlineSerializer).returns(Schema) }
    def add_serializer(field_name, serializer)
      self.class.new(
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

    sig { returns(Typed::HashSerializer) }
    def hash_serializer
      @hash_serializer = T.let(@hash_serializer, T.nilable(Typed::HashSerializer))
      @hash_serializer ||= Typed::HashSerializer.new(schema: self)
    end

    sig { returns(Typed::JSONSerializer) }
    def json_serializer
      @json_serializer = T.let(@json_serializer, T.nilable(Typed::JSONSerializer))
      @json_serializer ||= Typed::JSONSerializer.new(schema: self)
    end
  end
end
