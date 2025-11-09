# typed: strict

require "date"

module Typed
  module Coercion
    class DateCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: Date} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def self.used_for_type?(type)
        T::Utils.coerce(type) == T::Utils.coerce(Date)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Type must be a Date.")) unless self.class.used_for_type?(type)

        return Success.new(value) if value.is_a?(Date)

        Success.new(Date.parse(value))
      rescue Date::Error, TypeError
        Failure.new(CoercionError.new("'#{value}' cannot be coerced into Date."))
      end
    end
  end
end
