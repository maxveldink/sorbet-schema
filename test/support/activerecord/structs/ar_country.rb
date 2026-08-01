# typed: strict
# frozen_string_literal: true

class ARCountry < T::Struct
  include ActsAsComparable

  const :name, String
end
