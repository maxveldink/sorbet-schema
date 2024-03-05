# typed: strict

module Typed
  module Coercion
    class IntegerCoercer
      extend T::Sig
      extend T::Generic

      extend Coercer

      Target = type_template { {fixed: Integer} }

      sig { override.params(field: Field, value: Value).returns(Result[Target, CoercionError]) }
      def self.coerce(field:, value:)
        Success.new(Integer(value))
      rescue ArgumentError, TypeError
        Failure.new(CoercionError.new("'#{value}' cannot be coerced into Integer."))
      end
    end
  end
end
