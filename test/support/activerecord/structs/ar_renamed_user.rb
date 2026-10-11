# typed: strict
# frozen_string_literal: true

require_relative "ar_location"

class ARRenamedUser < T::Struct
  include ActsAsComparable

  const :name, String, name: "displayName"
  const :age, Integer
  const :location, ARLocation, name: "homeLocation"
end
