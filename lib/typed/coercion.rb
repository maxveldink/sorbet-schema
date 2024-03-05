# typed: strict

module Typed
  module Coercion
    extend T::Sig

    sig { type_parameters(:U).params(field: Field, value: Value).returns(Result[Value, CoercionError]) }
    def self.coerce(field:, value:)
      if field.type < T::Struct
        StructCoercer.coerce(field:, value:)
      else
        NoOpCoercer.coerce(field:, value:)
      end
    end
  end
end
