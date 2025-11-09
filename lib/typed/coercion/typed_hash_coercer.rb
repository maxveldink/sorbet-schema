# typed: strict

module Typed
  module Coercion
    class TypedHashCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: T::Hash[T.untyped, T.untyped]} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def self.used_for_type?(type)
        type.is_a?(T::Types::TypedHash)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Field type must be a T::Hash.")) unless self.class.used_for_type?(type)
        return Failure.new(CoercionError.new("Value must be a Hash.")) unless value.is_a?(Hash)

        return Success.new(value) if type.recursively_valid?(value)

        coerced_hash = {}
        errors = []

        value.each do |k, v|
          key_result = Coercion.coerce(type: T::Utils.coerce(T.cast(type, T::Types::TypedHash).type.types.first), value: k)
          value_result = Coercion.coerce(type: T::Utils.coerce(T.cast(type, T::Types::TypedHash).type.types.last), value: v)

          if key_result.success? && value_result.success?
            coerced_hash[key_result.payload] = value_result.payload
          else
            if key_result.failure?
              errors << key_result.error
            end

            if value_result.failure?
              errors << value_result.error
            end
          end
        end

        if errors.empty?
          Success.new(coerced_hash)
        else
          Failure.new(CoercionError.new(errors.map(&:message).join(" | ")))
        end
      end
    end
  end
end
