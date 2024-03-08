# typed: strict

module Typed
  module Coercion
    extend T::Sig

    sig { params(coercer: T.class_of(Coercer)).void }
    def self.register_coercer(coercer)
      CoercerRegistry.instance.register(coercer)
    end

    sig { type_parameters(:U).params(field: Field, value: Value).returns(Result[Value, CoercionError]) }
    def self.coerce(field:, value:)
      coercer = CoercerRegistry.instance.select_coercer_by(type: field.type)

      return Failure.new(CoercionNotSupportedError.new) unless coercer

      coercer.new.coerce(field: field, value: value)
    end
  end
end
