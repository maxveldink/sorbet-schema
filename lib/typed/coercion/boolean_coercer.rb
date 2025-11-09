# typed: strict

module Typed
  module Coercion
    class BooleanCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: T::Boolean} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def self.used_for_type?(type)
        type == T::Utils.coerce(T::Boolean)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Type must be a T::Boolean.")) unless self.class.used_for_type?(type)

        if type.recursively_valid?(value)
          Success.new(value)
        elsif value == "true"
          Success.new(true)
        elsif value == "false"
          Success.new(false)
        else
          Failure.new(CoercionError.new)
        end
      end
    end
  end
end
