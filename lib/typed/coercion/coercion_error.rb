# typed: strict

module Typed
  module Coercion
    class CoercionError < StandardError
      extend T::Sig

      sig { params(message: T.nilable(String)).void }
      def initialize(message = nil)
        super(message || "Coercion failed.")
      end
    end
  end
end