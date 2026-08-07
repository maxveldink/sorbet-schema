# typed: strict
# frozen_string_literal: true

require_relative "ar_location"

class ARUserHome < T::Struct
  include ActsAsComparable

  const :name, String
  const :home, T.nilable(ARLocation)
end
