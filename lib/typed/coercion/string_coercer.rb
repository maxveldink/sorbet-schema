# typed: strict

module Typed
  module Coercion
    class StringCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: String} }

      sig { override.params(type: Field::Type).returns(T::Boolean) }
      def used_for_type?(type)
        type == String
      end

      sig { override.params(type: Field::Type, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        Success.new(String(value))
      end
    end
  end
end
