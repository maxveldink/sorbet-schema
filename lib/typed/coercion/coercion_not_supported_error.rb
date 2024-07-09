# typed: strict

module Typed
  module Coercion
    class CoercionNotSupportedError < CoercionError
      extend T::Sig

      sig { params(type: T::Types::Base).void }
      def initialize(type:)
        super("Coercer not found for type #{type}.")
      end
    end
  end
end
