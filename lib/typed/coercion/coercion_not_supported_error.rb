# typed: strict

module Typed
  module Coercion
    class CoercionNotSupportedError < CoercionError
      extend T::Sig

      sig { params(type: T::Types::Base, value: Value).void }
      def initialize(type:, value: nil)
        super("Coercer not found for type #{type}. Value: #{value.inspect} (#{value.class}).")
      end
    end
  end
end
