# typed: strict

module Typed
  module Coercion
    class SymbolCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: Symbol} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def used_for_type?(type)
        type == T::Utils.coerce(Symbol)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Type must be a Symbol.")) unless used_for_type?(type)

        if value.respond_to?(:to_sym)
          Success.new(value.to_sym)
        else
          Failure.new(CoercionError.new("Value cannot be coerced into Symbol. Consider adding a #to_sym implementation."))
        end
      end
    end
  end
end
