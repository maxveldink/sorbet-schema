# typed: strict

module Typed
  # Serializes a collection of one schema's target structs. This is deliberately
  # separate from Serializer so the latter can continue to promise one struct in
  # each Result payload.
  class ArraySerializer
    extend T::Sig

    Format = T.type_alias { T.any(Symbol, String) }
    DeserializeResult = T.type_alias { Result[T::Array[T::Struct], DeserializeError] }
    SerializeOutput = T.type_alias { T.any(String, T::Array[Serializer::Params]) }
    SerializeResult = T.type_alias { Result[SerializeOutput, SerializeError] }

    sig { returns(Schema) }
    attr_reader :schema

    sig { returns(Symbol) }
    attr_reader :format

    sig { params(schema: Schema, format: Format).void }
    def initialize(schema:, format:)
      @schema = schema
      @format = T.let(normalize_format(format), Symbol)
      require_format_dependency
      @item_serializer = T.let(
        HashSerializer.new(schema:, should_serialize_values: @format != :hash),
        HashSerializer
      )
    end

    sig { params(source: T.untyped).returns(DeserializeResult) }
    def deserialize(source)
      values = parse(source)
      return values if values.failure?

      deserialize_values(values.payload)
    end

    sig { params(structs: T.untyped).returns(SerializeResult) }
    def serialize(structs)
      return Failure.new(SerializeError.new("Expected an Array of '#{schema.target}' structs.")) unless structs.is_a?(Array)

      rows = serialize_structs(structs)
      return rows if rows.failure?

      serialize_rows(rows.payload)
    end

    private

    sig { params(format: Format).returns(Symbol) }
    def normalize_format(format)
      normalized_format = format.to_sym
      normalized_format = :yml if normalized_format == :yaml

      return normalized_format if [:hash, :json, :yml, :msgpack, :csv].include?(normalized_format)

      raise ArgumentError, "unknown array serializer format for #{format}"
    end

    sig { void }
    def require_format_dependency
      case format
      when :json
        require "json"
      when :yml
        require "date"
        require "yaml"
      when :msgpack
        require_optional_dependency("msgpack", "MessagePack")
      when :csv
        require_optional_dependency("csv", "CSV")
      end
    end

    sig { params(gem_name: String, serializer_name: String).void }
    def require_optional_dependency(gem_name, serializer_name)
      require gem_name
    rescue LoadError
      raise ArgumentError, "#{gem_name} gem is required for #{serializer_name} serialization - add it to your Gemfile"
    end

    sig { params(source: T.untyped).returns(Result[T::Array[T.untyped], DeserializeError]) }
    def parse(source)
      case format
      when :hash
        validate_array_root(source)
      when :json
        parse_json(source)
      when :yml
        parse_yml(source)
      when :msgpack
        parse_msgpack(source)
      when :csv
        parse_csv(source)
      else
        raise ArgumentError, "unknown array serializer format for #{format}"
      end
    end

    sig { params(source: T.untyped).returns(Result[T::Array[T.untyped], DeserializeError]) }
    def parse_json(source)
      return root_error unless source.is_a?(String)

      validate_array_root(JSON.parse(source))
    rescue JSON::ParserError
      Failure.new(ParseError.new(format:))
    end

    sig { params(source: T.untyped).returns(Result[T::Array[T.untyped], DeserializeError]) }
    def parse_yml(source)
      return root_error unless source.is_a?(String)

      validate_array_root(YAML.safe_load(source, permitted_classes: [Date, Time]))
    rescue Psych::SyntaxError, Psych::DisallowedClass
      Failure.new(ParseError.new(format:))
    end

    sig { params(source: T.untyped).returns(Result[T::Array[T.untyped], DeserializeError]) }
    def parse_msgpack(source)
      return root_error unless source.is_a?(String)

      validate_array_root(MessagePack.unpack(source))
    rescue MessagePack::UnpackError, EOFError
      Failure.new(ParseError.new(format:))
    end

    sig { params(source: T.untyped).returns(Result[T::Array[T.untyped], DeserializeError]) }
    def parse_csv(source)
      return root_error unless source.is_a?(String)
      return Success.new([]) if source.empty?

      parsed = CSV.parse(source, headers: true)
      return Failure.new(ParseError.new(format:)) unless parsed.is_a?(CSV::Table)
      return Failure.new(ParseError.new(format:)) unless parsed.headers.tally == schema.fields.map { |field| field.name.to_s }.tally

      validate_array_root(parsed.map(&:to_h))
    rescue CSV::MalformedCSVError
      Failure.new(ParseError.new(format:))
    end

    sig { params(value: T.untyped).returns(Result[T::Array[T.untyped], DeserializeError]) }
    def validate_array_root(value)
      return root_error unless value.is_a?(Array)

      Success.new(value)
    end

    sig { returns(Failure[DeserializeError]) }
    def root_error
      Failure.new(DeserializeError.new("Expected an Array at the #{format} document root."))
    end

    sig { params(values: T::Array[T.untyped]).returns(DeserializeResult) }
    def deserialize_values(values)
      structs = T.let([], T::Array[T::Struct])

      values.each_with_index do |value, index|
        unless value.is_a?(Hash)
          return Failure.new(DeserializeError.new("Item at index #{index} must be a mapping."))
        end

        result = @item_serializer.deserialize(value)
        return indexed_deserialize_error(index, result.error) if result.failure?

        structs << result.payload
      end

      Success.new(structs)
    end

    sig { params(index: Integer, error: DeserializeError).returns(Failure[DeserializeError]) }
    def indexed_deserialize_error(index, error)
      Failure.new(DeserializeError.new("Item at index #{index} could not be deserialized: #{error.message}"))
    end

    sig { params(structs: T::Array[T.untyped]).returns(Result[T::Array[Serializer::Params], SerializeError]) }
    def serialize_structs(structs)
      rows = T.let([], T::Array[Serializer::Params])

      structs.each_with_index do |struct, index|
        unless struct.is_a?(T::Struct)
          return Failure.new(SerializeError.new("Item at index #{index} is not a T::Struct."))
        end

        result = @item_serializer.serialize(struct)
        return indexed_serialize_error(index, result.error) if result.failure?

        rows << result.payload
      end

      Success.new(rows)
    end

    sig { params(index: Integer, error: SerializeError).returns(Failure[SerializeError]) }
    def indexed_serialize_error(index, error)
      Failure.new(SerializeError.new("Item at index #{index} could not be serialized: #{error.message}"))
    end

    sig { params(rows: T::Array[Serializer::Params]).returns(SerializeResult) }
    def serialize_rows(rows)
      case format
      when :hash
        Success.new(rows)
      when :json
        Success.new(JSON.generate(rows))
      when :yml
        Success.new(YAML.dump(HashTransformer.stringify_keys(rows)))
      when :msgpack
        Success.new(MessagePack.pack(rows))
      when :csv
        serialize_csv_rows(rows)
      else
        raise ArgumentError, "unknown array serializer format for #{format}"
      end
    end

    sig { params(rows: T::Array[Serializer::Params]).returns(SerializeResult) }
    def serialize_csv_rows(rows)
      non_scalar_fields = rows.flat_map { |row| non_scalar_field_names(row) }.uniq
      unless non_scalar_fields.empty?
        return Failure.new(SerializeError.new("'#{schema.target}' cannot be serialized to CSV because field(s) #{non_scalar_fields.join(", ")} are not scalar values."))
      end

      headers = schema.fields.map(&:name)
      Success.new(CSV.generate do |csv|
        csv << headers.map(&:to_s)
        rows.each { |row| csv << headers.map { |header| row[header] } }
      end)
    end

    sig { params(params: Serializer::Params).returns(T::Array[Symbol]) }
    def non_scalar_field_names(params)
      params.select { |_key, value| value.is_a?(Hash) || value.is_a?(Array) }.keys
    end
  end
end
