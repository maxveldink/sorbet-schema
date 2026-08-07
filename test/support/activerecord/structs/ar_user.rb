# typed: strict
# frozen_string_literal: true

require_relative "ar_location"

class ARUser < T::Struct
  include ActsAsComparable

  const :name, String
  const :age, Integer
  const :location, ARLocation
end
