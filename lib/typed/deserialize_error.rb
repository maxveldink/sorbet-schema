# typed: strict

module Typed
  class DeserializeError < StandardError
    extend T::Sig

    sig { returns({error: String}) }
    def to_h
      {error: message}
    end

    sig { returns(String) }
    def to_json
      JSON.generate(to_h)
    end
  end
end
