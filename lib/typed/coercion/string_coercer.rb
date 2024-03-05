# typed: strict

module Typed
  module Coercion
    class StringCoercer
      extend T::Sig
      extend T::Generic

      extend Coercer

      Target = type_template { {fixed: String} }

      sig { override.params(field: Field, value: Value).returns(Result[Target, CoercionError]) }
      def self.coerce(field:, value:)
        Success.new(String(value))
      end
    end
  end
end
