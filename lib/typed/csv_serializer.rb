# typed: strict

require "csv"

module Typed
  # Nested structs/hashes/arrays can't round-trip through CSV; see README's
  # CSVSerializer section for the caveat.
  class CSVSerializer < Serializer
    Input = type_member { {fixed: String} }
    Output = type_member { {fixed: String} }

    sig { override.params(source: Input).returns(Result[T::Struct, DeserializeError]) }
    def deserialize(source)
      row = T.unsafe(CSV).parse(source, headers: true).first
      return Failure.new(ParseError.new(format: :csv)) if row.nil?

      creation_params = schema.fields.each_with_object(T.let({}, Params)) do |field, hsh|
        hsh[field.name] = row[field.name.to_s]
      end

      deserialize_from_creation_params(creation_params)
    rescue CSV::MalformedCSVError
      Failure.new(ParseError.new(format: :csv))
    end

    sig { override.params(struct: T::Struct).returns(Result[Output, SerializeError]) }
    def serialize(struct)
      return Failure.new(SerializeError.new("'#{struct.class}' cannot be serialized to target type of '#{schema.target}'.")) if struct.class != schema.target

      hsh = serialize_from_struct(struct:, should_serialize_values: true)

      csv_string = CSV.generate do |csv|
        csv << hsh.keys.map(&:to_s)
        csv << hsh.values
      end

      Success.new(csv_string)
    end
  end
end
