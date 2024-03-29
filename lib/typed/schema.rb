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
          Typed::Field.new(name: name, type: properties[:type], required: !properties[:fully_optional])
        end
      )
    end

    sig { params(hash: Typed::HashSerializer::InputHash).returns(Typed::Serializer::DeserializeResult) }
    def from_hash(hash)
      Typed::HashSerializer.new(schema: self).deserialize(hash)
    end

    sig { params(json: String).returns(Typed::Serializer::DeserializeResult) }
    def from_json(json)
      Typed::JSONSerializer.new(schema: self).deserialize(json)
    end

    sig { params(field_name: Symbol, serializer: Field::InlineSerializer).returns(Schema) }
    def add_serializer(field_name, serializer)
      self.class.new(
        target: target,
        fields: fields.map do |field|
          if field.name == field_name
            Field.new(name: field.name, type: field.type, required: field.required, inline_serializer: serializer)
          else
            field
          end
        end
      )
    end
  end
end
