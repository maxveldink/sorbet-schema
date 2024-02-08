# typed: strict

module Typed
  class Schema < T::Struct
    const :target, T.class_of(T::Struct)
  end
end
