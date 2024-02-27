# typed: strict

module T
  class Struct
    extend T::Sig

    sig { returns(Typed::Schema) }
    def self.create_schema
      Typed::Schema.new(
        target: self,
        fields: props.map do |name, properties|
          Typed::Field.new(name:, type: properties[:type], required: !properties[:fully_optional])
        end
      )
    end
  end
end
