# typed: strict

module Typed
  class ParseError < DeserializeError
    extend T::Sig

    sig { params(format: Symbol).void }
    def initialize(format:)
      super("#{format} could not be parsed. Check for typos.")
    end
  end
end
