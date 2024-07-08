# typed: true

class City < T::Struct
  include ActsAsComparable

  const :name, String
  const :capital, T::Boolean
  const :data, T.nilable(T::Hash[String, Integer])
end

NEW_YORK_CITY = City.new(name: "New York", capital: false)
DC_CITY = City.new(name: "DC", capital: true)
OVIEDO_CITY = City.new(name: "Oviedo", capital: false, data: {"how many maxes live here?" => 1})
