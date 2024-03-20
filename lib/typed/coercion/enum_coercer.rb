# typed: strict

module Typed
  module Coercion
    class EnumCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: T::Enum} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def used_for_type?(type)
        return false unless type.respond_to?(:raw_type)

        !!(T.cast(type, T::Types::Simple).raw_type < T::Enum)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Field type must inherit from T::Enum for Enum coercion.")) unless used_for_type?(type)

        Success.new(T.cast(type, T::Types::Simple).raw_type.from_serialized(value))
      rescue KeyError => e
        Failure.new(CoercionError.new(e.message))
      end
    end
  end
end
