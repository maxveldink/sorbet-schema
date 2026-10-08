# typed: strict

module Typed
  module Coercion
    class StructCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: StructValue} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def self.used_for_type?(type)
        return false unless type.respond_to?(:raw_type)

        raw_type = T.cast(type, T::Types::Simple).raw_type
        !!(raw_type < T::Struct || raw_type < T::ImmutableStruct)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Field type must inherit from T::Struct or T::ImmutableStruct for Struct coercion.")) unless self.class.used_for_type?(type)
        return Success.new(value) if type.recursively_valid?(value)

        return Failure.new(CoercionError.new("Value of type '#{value.class}' cannot be coerced to #{type} Struct.")) unless value.is_a?(Hash)

        struct_class = T.cast(T.cast(type, T::Types::Simple).raw_type, T.class_of(T::Struct))
        deserialization_result = struct_class.deserialize_from(:hash, value)

        if deserialization_result.success?
          Success.new(deserialization_result.payload)
        else
          Failure.new(CoercionError.new(deserialization_result.error.message))
        end
      rescue ArgumentError, RuntimeError
        Failure.new(CoercionError.new("Given hash could not be coerced to #{type}."))
      end
    end
  end
end
