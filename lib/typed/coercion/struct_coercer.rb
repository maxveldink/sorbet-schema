# typed: strict

module Typed
  module Coercion
    class StructCoercer
      extend T::Sig
      extend T::Generic

      extend Coercer

      Target = type_template { {fixed: T::Struct} }

      sig { override.params(field: Field, value: Value).returns(Result[Target, CoercionError]) }
      def self.coerce(field:, value:)
        type = field.type

        return Failure.new(CoercionError.new) unless type < T::Struct

        Success.new(type.from_hash!(value))
      rescue ArgumentError => e
        Failure.new(CoercionError.new(e.message))
      end
    end
  end
end
