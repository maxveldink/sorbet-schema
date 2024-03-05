# typed: strict

module Typed
  module Coercion
    extend T::Sig

    # TODO: We can definitely improve how we select which coercer to use
    #   Related issues:
    #   * https://github.com/maxveldink/sorbet-schema/issues/9
    #   * https://github.com/maxveldink/sorbet-schema/issues/10
    sig { type_parameters(:U).params(field: Field, value: Value).returns(Result[Value, CoercionError]) }
    def self.coerce(field:, value:)
      if field.type < T::Struct
        StructCoercer.coerce(field: field, value: value)
      elsif field.type == String
        StringCoercer.coerce(field: field, value: value)
      elsif field.type == Integer
        IntegerCoercer.coerce(field: field, value: value)
      elsif field.type == Float
        FloatCoercer.coerce(field: field, value: value)
      else
        Failure.new(CoercionNotSupportedError.new)
      end
    end
  end
end
