# typed: strict

require "json"

module Typed
  class JSONSerializer < Serializer
    extend T::Sig

    sig { override.params(source: String).returns(Result[T::Struct, DeserializeError]) }
    def deserialize(source)
      parsed_json = JSON.parse(source)

      creation_params = schema.fields.each_with_object(T.let({}, Params)) do |field, hsh|
        hsh[field.name] = parsed_json[field.name.to_s]
      end

      results = creation_params.map do |name, value|
        schema.field(name:)&.validate(value)
      end.compact

      Validations::ValidationResults
        .new(results:)
        .combine
        .and_then do
          Success.new(schema.target.new(**creation_params))
        end
    rescue JSON::ParserError
      Failure.new(ParseError.new(format: :json))
    end

    sig { override.params(struct: T::Struct).returns(String) }
    def serialize(struct)
      JSON.generate(struct.serialize)
    end
  end
end
