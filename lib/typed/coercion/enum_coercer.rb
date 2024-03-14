# typed: strict

module Typed
  module Coercion
    class EnumCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: T::Enum} }

      sig { override.params(type: Field::Type).returns(T::Boolean) }
      def used_for_type?(type)
        type.is_a?(Class) && !!(type < T::Enum)
      end

      sig { override.params(type: Field::Type, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Field type must inherit from T::Enum for Enum coercion.")) unless type.is_a?(Class) && !!(type < T::Enum)

        Success.new(type.from_serialized(value))
      rescue KeyError => e
        Failure.new(CoercionError.new(e.message))
      end
    end
  end
end
