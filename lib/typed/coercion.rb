# typed: strict

module Typed
  module Coercion
    extend T::Sig

    sig { type_parameters(:U).params(field: Field, value: Value).returns(Result[Value, CoercionError]) }
    def self.coerce(field:, value:)
      if field.type < T::Struct
        StructCoercer.coerce(field: field, value: value)
      elsif field.type == String
        StringCoercer.coerce(field: field, value: value)
      else
        Failure.new(CoercionNotSupportedError.new)
      end
    end
  end
end
