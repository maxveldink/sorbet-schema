# typed: strict

require "json"

module Typed
  class JSONSerializer < Serializer
    Input = type_member { {fixed: String} }
    Output = type_member { {fixed: String} }

    sig { override.params(source: Input).returns(Result[T::Struct, DeserializeError]) }
    def deserialize(source)
      parsed_json = JSON.parse(source)

      creation_params = schema.fields.each_with_object(T.let({}, Params)) do |field, hsh|
        hsh[field.name] = parsed_json[field.name.to_s]
      end

      deserialize_from_creation_params(creation_params)
    rescue JSON::ParserError
      Failure.new(ParseError.new(format: :json))
    end

    sig { override.params(struct: T::Struct).returns(Result[Output, SerializeError]) }
    def serialize(struct)
      return Failure.new(SerializeError.new("'#{struct.class}' cannot be serialized to target type of '#{schema.target}'.")) if struct.class != schema.target

      Success.new(JSON.generate(serialize_from_struct(struct: struct, should_serialize_values: true)))
    end
  end
end
