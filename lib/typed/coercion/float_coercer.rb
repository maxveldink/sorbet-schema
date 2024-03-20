# typed: strict

module Typed
  module Coercion
    class FloatCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: Float} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def used_for_type?(type)
        T::Utils.coerce(type) == T::Utils.coerce(Float)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Type must be a Float.")) unless used_for_type?(type)

        Success.new(Float(value))
      rescue ArgumentError, TypeError
        Failure.new(CoercionError.new("'#{value}' cannot be coerced into Float."))
      end
    end
  end
end
