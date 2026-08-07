# typed: strict

module Typed
  class MessagePackSerializer < Serializer
    # MessagePack packs to a binary (`ASCII-8BIT`) encoded string, not text,
    # but `String` is still the correct Sorbet type for it, same as `Input`/`Output`
    # on the other serializers.
    Input = type_member { {fixed: String} }
    Output = type_member { {fixed: String} }
    StructT = type_member { {upper: T::Struct} }

    sig { params(schema: Schema[StructT]).void }
    def initialize(schema:)
      require "msgpack"
      super
    rescue LoadError
      raise ArgumentError, "msgpack gem is required for MessagePack serialization - add it to your Gemfile"
    end

    sig { override.params(source: Input).returns(Result[StructT, DeserializeError]) }
    def deserialize(source)
      parsed_msgpack = MessagePack.unpack(source)
      return Failure.new(ParseError.new(format: :msgpack)) unless parsed_msgpack.is_a?(Hash)

      creation_params = schema.fields.each_with_object(T.let({}, Params)) do |field, hsh|
        hsh[field.name] = parsed_msgpack[field.name.to_s]
      end

      deserialize_from_creation_params(creation_params)
    rescue MessagePack::UnpackError, EOFError
      Failure.new(ParseError.new(format: :msgpack))
    end

    sig { override.params(struct: StructT).returns(Result[Output, SerializeError]) }
    def serialize(struct)
      return Failure.new(SerializeError.new("'#{struct.class}' cannot be serialized to target type of '#{schema.target}'.")) if struct.class != schema.target

      Success.new(MessagePack.pack(serialize_from_struct(struct:, should_serialize_values: true)))
    end
  end
end
