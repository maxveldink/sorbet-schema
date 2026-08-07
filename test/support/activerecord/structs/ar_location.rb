# typed: strict
# frozen_string_literal: true

require_relative "ar_country"

class ARLocation < T::Struct
  include ActsAsComparable

  const :name, String
  const :country, T.nilable(ARCountry)
end
