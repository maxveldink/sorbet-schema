# typed: strict

module Typed
  module Coercion
    class IntegerCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: Integer} }

      sig { override.params(type: Field::Type).returns(T::Boolean) }
      def used_for_type?(type)
        type == Integer
      end

      sig { override.params(type: Field::Type, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        Success.new(Integer(value))
      rescue ArgumentError, TypeError
        Failure.new(CoercionError.new("'#{value}' cannot be coerced into Integer."))
      end
    end
  end
end
