# typed: strict

module Typed
  module Validations
    class ValidatedValue < T::Struct
      include ActsAsComparable

      const :name, Symbol
      const :value, Value
    end
  end
end
