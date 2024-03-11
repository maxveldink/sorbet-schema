# typed: strict

module T
  class Struct
    extend T::Sig

    sig { returns(Typed::Schema) }
    def self.create_schema
      Typed::Schema.new(
        target: self,
        fields: props.map do |name, properties|
          Typed::Field.new(name: name, type: properties[:type], required: !properties[:fully_optional])
        end
      )
    end

    sig { params(hash: Typed::HashSerializer::InputHash).returns(Typed::Serializer::DeserializeResult) }
    def self.from_hash(hash)
      Typed::HashSerializer.new(schema: create_schema).deserialize(hash)
    end

    sig { params(json: String).returns(Typed::Serializer::DeserializeResult) }
    def self.from_json(json)
      Typed::JSONSerializer.new(schema: create_schema).deserialize(json)
    end

    sig { returns(Typed::HashSerializer::OutputHash) }
    def to_hash
      Typed::HashSerializer.new(schema: self.class.create_schema).serialize(self)
    end

    sig { params(_options: T::Hash[T.untyped, T.untyped]).returns(String) }
    def to_json(_options = {})
      Typed::JSONSerializer.new(schema: self.class.create_schema).serialize(self)
    end
  end
end
