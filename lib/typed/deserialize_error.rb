# typed: strict

module Typed
  class DeserializeError < StandardError
    extend T::Sig

    sig { returns({error: String}) }
    def to_h
      {error: message}
    end

    sig { params(_options: T::Hash[T.untyped, T.untyped]).returns(String) }
    def to_json(_options = {})
      JSON.generate(to_h)
    end
  end
end
