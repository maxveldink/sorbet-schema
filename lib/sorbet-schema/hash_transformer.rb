# typed: strict

# We don't want a dependency on ActiveSupport.
# This is a simplified version of ActiveSupport's Key Hash extension
# https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/hash/keys.rb
class HashTransformer
  extend T::Sig

  sig { params(hash: T::Hash[T.untyped, T.untyped]).returns(T::Hash[Symbol, T.untyped]) }
  def deep_symbolize_keys(hash)
    hash.each_with_object({}) do |(key, value), result|
      result[key.to_sym] = value.is_a?(Hash) ? deep_symbolize_keys(value) : value
    end
  end

  sig { params(hash: T::Hash[T.untyped, T.untyped]).returns(T::Hash[String, T.untyped]) }
  def deep_stringify_keys(hash)
    hash.each_with_object({}) do |(key, value), result|
      result[key.to_s] = value.is_a?(Hash) ? deep_stringify_keys(value) : value
    end
  end
end
