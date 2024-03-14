# typed: strict

module Typed
  module Coercion
    class BooleanCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: T::Boolean} }

      sig { override.params(type: Field::Type).returns(T::Boolean) }
      def used_for_type?(type)
        type == T::Utils.coerce(T::Boolean)
      end

      sig { override.params(field: Field, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(field:, value:)
        if T.cast(field.type, T::Types::Base).recursively_valid?(value)
          Success.new(value)
        elsif value == "true"
          Success.new(true)
        elsif value == "false"
          Success.new(false)
        else
          Failure.new(CoercionError.new)
        end
      rescue TypeError
        Failure.new(CoercionError.new("Field type must be a T::Boolean."))
      end
    end
  end
end
