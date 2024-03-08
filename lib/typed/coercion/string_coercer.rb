# typed: strict

module Typed
  module Coercion
    class StringCoercer < Coercer
      extend T::Sig
      extend T::Generic

      Target = type_member { {fixed: String} }

      sig { override.params(field: Field, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(field:, value:)
        Success.new(String(value))
      end
    end
  end
end
