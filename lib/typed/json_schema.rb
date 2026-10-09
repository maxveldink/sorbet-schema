# typed: strict

module Typed
  # Generates a JSON Schema (draft 2020-12) describing the hash a `Typed::Schema`
  # deserializes from: keys are the fields' serialized names, values are in their
  # serialized form (a `T::Enum` by its serialized value, a `Date` as an ISO 8601
  # string). A type the generator has no JSON form for raises instead of being
  # silently described as something it isn't.
  module JSONSchema
    extend T::Sig

    class UnsupportedTypeError < StandardError; end

    Document = T.type_alias { T::Hash[String, T.untyped] }

    # How a nested struct's schema is found. Defaults to the struct's own `schema`,
    # which is what deserialization uses.
    StructSchema = T.type_alias { T.proc.params(struct: StructClass).returns(Schema[T.untyped]) }

    # What a generation needs at every depth.
    class Options < T::Struct
      const :struct_schema, StructSchema
      const :additional_properties, T::Boolean
    end

    SIMPLE_TYPES = T.let(
      {
        String => {"type" => "string"},
        Symbol => {"type" => "string"},
        Integer => {"type" => "integer"},
        Float => {"type" => "number"},
        Date => {"type" => "string", "format" => "date"},
        DateTime => {"type" => "string", "format" => "date-time"}
      }.freeze,
      T::Hash[T.anything, Document]
    )

    BOOLEAN = T.let(T::Utils.coerce(T::Boolean), T::Types::Base)
    private_constant :BOOLEAN

    # Deserialization ignores keys a schema doesn't know. `additional_properties: false`
    # rejects them in every struct object instead, e.g. to catch typos in a config file
    # or to meet an LLM structured-output API that requires closed objects.
    sig do
      params(schema: Schema[T.untyped], struct_schema: T.nilable(StructSchema), additional_properties: T::Boolean).returns(Document)
    end
    def self.generate(schema, struct_schema: nil, additional_properties: true)
      resolve = struct_schema || ->(struct) { struct.schema }
      object(schema, Options.new(struct_schema: resolve, additional_properties:))
    end

    sig { params(schema: Schema[T.untyped], options: Options).returns(Document) }
    def self.object(schema, options)
      properties = schema.fields.to_h { |field| [field.serialized_name.to_s, property(schema, field, options)] }
      required = schema.fields.select(&:required?).map { |field| field.serialized_name.to_s }

      document = {"type" => "object", "properties" => properties}
      document = document.merge("required" => required) unless required.empty?
      options.additional_properties ? document : document.merge("additionalProperties" => false)
    end
    private_class_method :object

    sig { params(schema: Schema[T.untyped], field: Field, options: Options).returns(Document) }
    def self.property(schema, field, options)
      document = type(field.type, options)
      document = nullable(document) if field.nilable?
      description = field.description
      description.nil? ? document : document.merge("description" => description)
    rescue UnsupportedTypeError => e
      raise UnsupportedTypeError, "#{schema.target}.#{field.name}: #{e.message}"
    end
    private_class_method :property

    sig { params(type: T::Types::Base, options: Options).returns(Document) }
    def self.type(type, options)
      return {"type" => "boolean"} if type == BOOLEAN

      case type
      when T::Types::Untyped, T::Types::Anything then {}
      when T::Types::Simple then simple(type, options)
      when T::Types::TypedArray then {"type" => "array", "items" => type(type.type, options)}
      when T::Types::TypedHash then hash_type(type, options)
      when T::Types::Union then union(type, options)
      else raise UnsupportedTypeError, "#{type} has no JSON Schema"
      end
    end
    private_class_method :type

    sig { params(type: T::Types::Simple, options: Options).returns(Document) }
    def self.simple(type, options)
      raw_type = type.raw_type
      known = SIMPLE_TYPES[raw_type]
      return known unless known.nil?

      case raw_type
      when T::Enum.singleton_class then enum(raw_type)
      when T::Struct.singleton_class, T::ImmutableStruct.singleton_class then object(options.struct_schema.call(raw_type), options)
      else raise UnsupportedTypeError, "#{raw_type} has no JSON Schema"
      end
    end
    private_class_method :simple

    sig { params(enum: T.class_of(T::Enum)).returns(Document) }
    def self.enum(enum)
      values = enum.values.map(&:serialize)
      document = {"enum" => values}

      if values.all?(String)
        document.merge("type" => "string")
      elsif values.all?(Integer)
        document.merge("type" => "integer")
      else
        document
      end
    end
    private_class_method :enum

    # Keys of a JSON object are always strings.
    sig { params(type: T::Types::TypedHash, options: Options).returns(Document) }
    def self.hash_type(type, options)
      keys = type.keys
      string_keys = keys.is_a?(T::Types::Simple) && [String, Symbol].include?(keys.raw_type)
      raise UnsupportedTypeError, "#{type} has non-string keys" unless string_keys

      values = type(type.values, options)
      values.empty? ? {"type" => "object"} : {"type" => "object", "additionalProperties" => values}
    end
    private_class_method :hash_type

    sig { params(type: T::Types::Union, options: Options).returns(Document) }
    def self.union(type, options)
      non_nil = T::Utils.unwrap_nilable(type)
      return nullable(type(non_nil, options)) unless non_nil.nil?

      {"anyOf" => type.types.map { |member| type(member, options) }}
    end
    private_class_method :union

    sig { params(document: Document).returns(Document) }
    def self.nullable(document)
      type = document["type"]
      return document if document.empty?
      return {"anyOf" => [document, {"type" => "null"}]} unless type.is_a?(String)

      nullable = document.merge("type" => [type, "null"])
      enum = document["enum"]
      enum.nil? ? nullable : nullable.merge("enum" => [*enum, nil])
    end
    private_class_method :nullable
  end
end
