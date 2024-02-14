# typed: true

require "sorbet-struct-comparable"

class Person < T::Struct
  include T::Struct::ActsAsComparable

  const :name, String
  const :age, Integer
end
