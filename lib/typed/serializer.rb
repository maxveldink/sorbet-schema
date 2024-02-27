# typed: strict

module Typed
  class Serializer
    extend T::Sig
    extend T::Helpers
    extend T::Generic
    abstract!

    Input = type_member
    Output = type_member
    Params = T.type_alias { T::Hash[Symbol, T.untyped] }
    DeserializeResult = T.type_alias { Typed::Result[T::Struct, DeserializeError] }

    sig { returns(Schema) }
    attr_reader :schema

    sig { params(schema: Schema).void }
    def initialize(schema:)
      @schema = schema
    end

    sig { abstract.params(source: Output).returns(DeserializeResult) }
    def deserialize(source)
    end

    sig { abstract.params(struct: T::Struct).returns(Output) }
    def serialize(struct)
    end

    private

    sig { params(creation_params: Params).returns(DeserializeResult) }
    def deserialize_from_creation_params(creation_params)
      results = schema.fields.map do |field|
        field.validate(creation_params[field.name])
      end

      Validations::ValidationResults
        .new(results:)
        .combine
        .and_then do
          Success.new(schema.target.new(**creation_params))
        end
    end
  end
end
