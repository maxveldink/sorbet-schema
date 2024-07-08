# typed: strict

# We don't want a dependency on ActiveSupport.
# This is a simplified version of ActiveSupport's Key Hash extension
# https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/hash/keys.rb
class HashTransformer
  class << self
    extend T::Sig

    sig { params(hash: T::Hash[T.untyped, T.untyped]).returns(T::Hash[Symbol, T.untyped]) }
    def symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), result|
        result[key.to_sym] = value
      end
    end

    sig { params(hash: T::Hash[T.untyped, T.untyped]).returns(T::Hash[T.untyped, T.untyped]) }
    def serialize_values(hash)
      hash.each_with_object({}) do |(key, value), result|
        result[key] = SerializeValue.serialize(value)
      end
    end
  end
end
