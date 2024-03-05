# typed: strict

module Typed
  module Coercion
    class FloatCoercer
      extend T::Sig
      extend T::Generic

      extend Coercer

      Target = type_template { {fixed: Float} }

      sig { override.params(field: Field, value: Value).returns(Result[Target, CoercionError]) }
      def self.coerce(field:, value:)
        Success.new(Float(value))
      rescue ArgumentError, TypeError
        Failure.new(CoercionError.new("'#{value}' cannot be coerced into Float."))
      end
    end
  end
end
