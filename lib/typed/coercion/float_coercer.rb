# typed: strict

module Typed
  module Coercion
    class FloatCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: Float} }

      sig { override.params(type: Field::Type).returns(T::Boolean) }
      def used_for_type?(type)
        type == Float
      end

      sig { override.params(field: Field, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(field:, value:)
        Success.new(Float(value))
      rescue ArgumentError, TypeError
        Failure.new(CoercionError.new("'#{value}' cannot be coerced into Float."))
      end
    end
  end
end
