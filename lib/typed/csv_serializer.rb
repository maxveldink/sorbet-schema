# typed: strict

module Typed
  # CSV is a flat, row-based format, so nested structs/hashes/arrays cannot be
  # represented as their own columns. `serialize` fails with a `SerializeError`
  # naming the offending field(s) rather than writing a lossy representation
  # that `deserialize` could never parse back; see README's CSVSerializer
  # section for the caveat.
  class CSVSerializer < Serializer
    Input = type_member { {fixed: String} }
    Output = type_member { {fixed: String} }

    sig { params(schema: Schema).void }
    def initialize(schema:)
      require "csv"
      super
    rescue LoadError
      raise ArgumentError, "csv gem is required for CSV serialization - add it to your Gemfile"
    end

    sig { override.params(source: Input).returns(Result[T::Struct, DeserializeError]) }
    def deserialize(source)
      parsed = CSV.parse(source, headers: true)
      return Failure.new(ParseError.new(format: :csv)) unless parsed.is_a?(CSV::Table)

      row = parsed.first
      return Failure.new(ParseError.new(format: :csv)) unless row.is_a?(CSV::Row)

      creation_params = schema.fields.each_with_object(T.let({}, Params)) do |field, hsh|
        hsh[field.serialized_name] = row[field.serialized_name.to_s]
      end

      deserialize_from_creation_params(creation_params)
    rescue CSV::MalformedCSVError
      Failure.new(ParseError.new(format: :csv))
    end

    sig { override.params(struct: T::Struct).returns(Result[Output, SerializeError]) }
    def serialize(struct)
      return Failure.new(SerializeError.new("'#{struct.class}' cannot be serialized to target type of '#{schema.target}'.")) if struct.class != schema.target

      hsh = serialize_from_struct(struct:, should_serialize_values: true)

      non_scalar_fields = hsh.select { |_key, value| value.is_a?(Hash) || value.is_a?(Array) }.keys
      unless non_scalar_fields.empty?
        return Failure.new(SerializeError.new("'#{struct.class}' cannot be serialized to CSV because field(s) #{non_scalar_fields.join(", ")} are not scalar values."))
      end

      csv_string = CSV.generate do |csv|
        csv << hsh.keys.map(&:to_s)
        csv << hsh.values
      end

      Success.new(csv_string)
    end
  end
end
