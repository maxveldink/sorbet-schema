# typed: strict

require "json"

module Typed
  class JSONSerializer < Serializer
    Input = type_member { {fixed: String} }
    Output = type_member { {fixed: String} }

    sig { override.params(source: Input).returns(Result[T::Struct, DeserializeError]) }
    def deserialize(source)
      parsed_json = JSON.parse(source, symbolize_names: true)
      deserialize_from_creation_params(parsed_json)
    rescue JSON::ParserError
      Failure.new(ParseError.new(format: :json))
    end

    sig { override.params(struct: T::Struct).returns(Result[Output, SerializeError]) }
    def serialize(struct)
      return Failure.new(SerializeError.new("'#{struct.class}' cannot be serialized to target type of '#{schema.target}'.")) if struct.class != schema.target

      hash_result = serialize_from_struct(struct:, should_serialize_values: true)
      Success.new(JSON.generate(hash_result))
    rescue JSON::GeneratorError
      Failure.new(SerializeError.new("Failed to generate JSON from struct."))
    end
  end
end