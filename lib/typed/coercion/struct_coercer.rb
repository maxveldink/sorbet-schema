# typed: strict

module Typed
  module Coercion
    class StructCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: T::Struct} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def used_for_type?(type)
        return false unless type.respond_to?(:raw_type)

        !!(T.cast(type, T::Types::Simple).raw_type < T::Struct)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Field type must inherit from T::Struct for Struct coercion.")) unless used_for_type?(type)
        return Success.new(value) if type.recursively_valid?(value)

        return Failure.new(CoercionError.new("Value of type '#{value.class}' cannot be coerced to #{type} Struct.")) unless value.is_a?(Hash)

        Success.new(T.cast(type, T::Types::Simple).raw_type.from_hash!(HashTransformer.new.deep_stringify_keys(value)))
      rescue ArgumentError, RuntimeError
        Failure.new(CoercionError.new("Given hash could not be coerced to #{type}."))
      end
    end
  end
end
