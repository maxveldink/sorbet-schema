# typed: strict

require "date"

module Typed
  module Coercion
    class DateTimeCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: DateTime} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def self.used_for_type?(type)
        T::Utils.coerce(type) == T::Utils.coerce(DateTime)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Type must be a DateTime.")) unless self.class.used_for_type?(type)

        return Success.new(value) if value.is_a?(DateTime)

        Success.new(DateTime.parse(value))
      rescue Date::Error, TypeError
        Failure.new(CoercionError.new("'#{value}' cannot be coerced into DateTime."))
      end
    end
  end
end
