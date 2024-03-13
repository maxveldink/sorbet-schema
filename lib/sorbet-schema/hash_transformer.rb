# typed: strict

# We don't want a dependency on ActiveSupport.
# This is a simplified version of ActiveSupport's Key Hash extension
# https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/hash/keys.rb
class HashTransformer
  extend T::Sig

  sig { params(should_serialize_values: T::Boolean).void }
  def initialize(should_serialize_values: false)
    @should_serialize_values = should_serialize_values
  end

  sig { params(hash: T::Hash[T.untyped, T.untyped]).returns(T::Hash[Symbol, T.untyped]) }
  def deep_symbolize_keys(hash)
    hash.each_with_object({}) do |(key, value), result|
      result[key.to_sym] = transform_value(value, hash_transformation_method: :deep_symbolize_keys)
    end
  end

  sig { params(hash: T::Hash[T.untyped, T.untyped]).returns(T::Hash[String, T.untyped]) }
  def deep_stringify_keys(hash)
    hash.each_with_object({}) do |(key, value), result|
      result[key.to_s] = transform_value(value, hash_transformation_method: :deep_stringify_keys)
    end
  end

  private

  sig { returns(T::Boolean) }
  attr_reader :should_serialize_values

  sig { params(value: T.untyped, hash_transformation_method: Symbol).returns(T.untyped) }
  def transform_value(value, hash_transformation_method:)
    if value.is_a?(Hash)
      send(hash_transformation_method, value)
    elsif value.is_a?(Array)
      value.map { |inner_val| transform_value(inner_val, hash_transformation_method: hash_transformation_method) }
    elsif value.respond_to?(:serialize) && should_serialize_values
      value.serialize
    else
      value
    end
  end
end
