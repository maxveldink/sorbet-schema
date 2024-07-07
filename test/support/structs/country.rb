# typed: true

require_relative "city"

class Country < T::Struct
  include ActsAsComparable

  const :name, String
  const :cities, T::Array[City]
  const :national_items, T::Hash[Symbol, String], default: {}
end

US_COUNTRY = Country.new(name: "US", cities: [NEW_YORK_CITY, DC_CITY], national_items: {bird: "bald eagle", anthem: "The Star-Spangled Banner"})
