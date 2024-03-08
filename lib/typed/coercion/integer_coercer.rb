# typed: strict

module Typed
  module Coercion
    class IntegerCoercer < Coercer
      extend T::Sig
      extend T::Generic

      Target = type_member { {fixed: Integer} }

      sig { override.params(field: Field, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(field:, value:)
        Success.new(Integer(value))
      rescue ArgumentError, TypeError
        Failure.new(CoercionError.new("'#{value}' cannot be coerced into Integer."))
      end
    end
  end
end
