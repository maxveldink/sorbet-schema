# typed: strict

module Typed
  module Coercion
    class TypedArrayCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: T::Array[T.untyped]} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def used_for_type?(type)
        type.is_a?(T::Types::TypedArray)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Field type must be a T::Array.")) unless used_for_type?(type)
        return Failure.new(CoercionError.new("Value must be an Array.")) unless value.is_a?(Array)

        return Success.new(value) if type.recursively_valid?(value)

        coerced_results = value.map do |item|
          Coercion.coerce(type: T.cast(type, T::Types::TypedArray).type, value: item)
        end

        if coerced_results.all?(&:success?)
          Success.new(coerced_results.map(&:payload))
        else
          Failure.new(CoercionError.new(coerced_results.select(&:failure?).map(&:error).map(&:message).join(" | ")))
        end
      end
    end
  end
end
