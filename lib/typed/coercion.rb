# typed: strict

module Typed
  module Coercion
    extend T::Sig

    sig { params(coercer: T.class_of(Coercer)).void }
    def self.register_coercer(coercer)
      CoercerRegistry.instance.register(coercer)
    end

    sig { type_parameters(:U).params(type: T::Types::Base, value: Value).returns(Result[Value, CoercionError]) }
    def self.coerce(type:, value:)
      coercer = CoercerRegistry.instance.select_coercer_by(type: type)

      return Failure.new(CoercionNotSupportedError.new) unless coercer

      coercer.new.coerce(type: type, value: value)
    end
  end
end
