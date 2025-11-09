# typed: strict

module Typed
  module Coercion
    class StringCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: String} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def self.used_for_type?(type)
        type == T::Utils.coerce(String)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Type must be a String.")) unless self.class.used_for_type?(type)

        Success.new(String(value))
      end
    end
  end
end
