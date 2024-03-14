# typed: strict

module Typed
  module Coercion
    class TypedArrayCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: T::Array[T.untyped]} }

      sig { override.params(type: Field::Type).returns(T::Boolean) }
      def used_for_type?(type)
        type.is_a?(T::Types::TypedArray)
      end

      sig { override.params(type: Field::Type, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Field type must be a T::Array.")) unless type.is_a?(T::Types::TypedArray)
        return Failure.new(CoercionError.new("Value must be an Array.")) unless value.is_a?(Array)

        return Success.new(value) if type.recursively_valid?(value)

        coerced_results = value.map do |item|
          Coercion.coerce(type: type.type.raw_type, value: item)
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
