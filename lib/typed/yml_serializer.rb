# typed: strict

require "yaml"

module Typed
  class YMLSerializer < Serializer
    Input = type_member { {fixed: String} }
    Output = type_member { {fixed: String} }

    sig { override.params(source: Input).returns(Result[T::Struct, DeserializeError]) }
    def deserialize(source)
      parsed_yaml = YAML.safe_load(source, permitted_classes: [Date, Time], symbolize_names: true)
      return Failure.new(ParseError.new(format: :yml)) unless parsed_yaml.is_a?(Hash)

      creation_params = schema.fields.each_with_object(T.let({}, Params)) do |field, hsh|
        hsh[field.name] = parsed_yaml[field.name]
      end

      deserialize_from_creation_params(creation_params)
    rescue Psych::SyntaxError, Psych::DisallowedClass
      Failure.new(ParseError.new(format: :yml))
    end

    sig { override.params(struct: T::Struct).returns(Result[Output, SerializeError]) }
    def serialize(struct)
      return Failure.new(SerializeError.new("'#{struct.class}' cannot be serialized to target type of '#{schema.target}'.")) if struct.class != schema.target

      Success.new(YAML.dump(stringify_keys(serialize_from_struct(struct:, should_serialize_values: true))))
    end

    private

    sig { params(value: T.untyped).returns(T.untyped) }
    def stringify_keys(value)
      case value
      when Hash
        value.each_with_object({}) { |(key, val), hsh| hsh[key.to_s] = stringify_keys(val) }
      when Array
        value.map { |item| stringify_keys(item) }
      else
        value
      end
    end
  end
end
