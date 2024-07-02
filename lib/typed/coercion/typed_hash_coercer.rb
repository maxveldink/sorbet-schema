# typed: strict

module Typed
  module Coercion
    class TypedHashCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: T::Hash[T.untyped, T.untyped]} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def used_for_type?(type)
        type.is_a?(T::Types::TypedHash)
      end

      # sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      # def coerce(type:, value:)
      #   return Failure.new(CoercionError.new("Field type must be a T::Hash.")) unless used_for_type?(type)
      #   return Failure.new(CoercionError.new("Value must be a Hash.")) unless value.is_a?(Hash)

      #   Success.new(value) if type.recursively_valid?(value)

      #   # coerced_results = value.map do |item|
      #   #   Coercion.coerce(type: T::Utils.coerce(key) T.cast(type, T::Types::TypedHash).type, value: item)
      #   # end

      #   # if coerced_results.all?(&:success?)
      #   #   Success.new(coerced_results.map(&:payload))
      #   # else
      #   #   Failure.new(CoercionError.new(coerced_results.select(&:failure?).map(&:error).map(&:message).join(" | ")))
      #   # end
      # end
    end
  end
end
