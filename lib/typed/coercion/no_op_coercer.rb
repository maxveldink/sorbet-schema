# typed: strict

module Typed
  module Coercion
    class NoOpCoercer
      extend T::Sig
      extend T::Generic

      extend Coercer

      Target = type_template { {fixed: T::Class[T.anything]} }

      sig { override.params(field: Field, value: Value).returns(Typed::Result[Target, CoercionError]) }
      def self.coerce(field:, value:)
        Success.new(value)
      end
    end
  end
end
