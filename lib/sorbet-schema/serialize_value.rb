# typed: strict

class SerializeValue
  extend T::Sig

  sig { params(value: T.untyped).returns(T.untyped) }
  def self.serialize(value)
    if value.is_a?(Hash)
      HashTransformer.serialize_values(value)
    elsif value.is_a?(Array)
      value.map { |item| serialize(item) }
    elsif value.is_a?(T::Struct)
      value.serialize_to(:nested_hash).payload_or(value)
    elsif value.respond_to?(:serialize)
      value.serialize
    else
      value
    end
  end
end
