# typed: strict

module Typed
  class HashSerializer < Serializer
    InputHash = T.type_alias { T::Hash[T.any(Symbol, String), T.untyped] }
    Input = type_member { {fixed: InputHash} }
    Output = type_member { {fixed: Params} }
    StructT = type_member { {upper: T::Struct} }

    sig { returns(T::Boolean) }
    attr_reader :should_serialize_values

    # Sorbet does not infer a class's type members from constructor argument
    # types, so without this override `HashSerializer.new(schema: klass.schema)`
    # would reveal as `HashSerializer[T.untyped]` instead of narrowing to the
    # struct type carried by `schema`.
    sig do
      type_parameters(:S)
        .params(schema: Schema[T.all(T::Struct, T.type_parameter(:S))], should_serialize_values: T::Boolean)
        .returns(HashSerializer[T.all(T::Struct, T.type_parameter(:S))])
    end
    def self.new(schema:, should_serialize_values: false)
      super
    end

    sig { params(schema: Schema[StructT], should_serialize_values: T::Boolean).void }
    def initialize(schema:, should_serialize_values: false)
      @should_serialize_values = should_serialize_values

      super(schema: schema)
    end

    sig { override.params(source: Input).returns(Result[StructT, DeserializeError]) }
    def deserialize(source)
      deserialize_from_creation_params(HashTransformer.symbolize_keys(source))
    end

    sig { override.params(struct: StructT).returns(Result[Output, SerializeError]) }
    def serialize(struct)
      return Failure.new(SerializeError.new("'#{struct.class}' cannot be serialized to target type of '#{schema.target}'.")) if struct.class != schema.target

      Success.new(serialize_from_struct(struct:, should_serialize_values:))
    end
  end
end
