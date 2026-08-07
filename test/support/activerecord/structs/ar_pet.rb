# typed: strict
# frozen_string_literal: true

class ARPet < T::Struct
  include ActsAsComparable

  const :name, String
  const :breed, String
end
