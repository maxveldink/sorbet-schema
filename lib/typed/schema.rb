# typed: strict

module Typed
  class Schema < T::Struct
    extend T::Sig

    const :fields, T::Array[Field], default: []
    const :target, T.class_of(T::Struct)

    sig { params(name: Symbol).returns(T.nilable(Field)) }
    def field(name:)
      fields.find { |field| field.name == name }
    end
  end
end
