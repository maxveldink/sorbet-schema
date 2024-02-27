# typed: strict

module Typed
  class Schema < T::Struct
    include T::Struct::ActsAsComparable

    const :fields, T::Array[Field], default: []
    const :target, T.class_of(T::Struct)
  end
end
