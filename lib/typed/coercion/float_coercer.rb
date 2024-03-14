# typed: strict

module Typed
  module Coercion
    class FloatCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: Float} }

      sig { override.params(type: Field::Type).returns(T::Boolean) }
      def used_for_type?(type)
        T::Utils.coerce(type) == T::Utils.coerce(Float)
      end

      sig { override.params(type: Field::Type, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        Success.new(Float(value))
      rescue ArgumentError, TypeError
        Failure.new(CoercionError.new("'#{value}' cannot be coerced into Float."))
      end
    end
  end
end
