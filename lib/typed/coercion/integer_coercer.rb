# typed: strict

module Typed
  module Coercion
    class IntegerCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: Integer} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def self.used_for_type?(type)
        type == T::Utils.coerce(Integer)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Type must be a Integer.")) unless self.class.used_for_type?(type)

        Success.new(Integer(value))
      rescue ArgumentError, TypeError
        Failure.new(CoercionError.new("'#{value}' cannot be coerced into Integer."))
      end
    end
  end
end
