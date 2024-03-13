# typed: true

require_relative "city"

class Country < T::Struct
  const :name, String
  const :cities, T::Array[City]
end

US_COUNTRY = Country.new(name: "US", cities: [NEW_YORK_CITY, DC_CITY])
