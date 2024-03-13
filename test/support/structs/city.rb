# typed: true

class City < T::Struct
  include ActsAsComparable

  const :name, String
  const :capital, T::Boolean
end

NEW_YORK_CITY = City.new(name: "New York", capital: false)
DC_CITY = City.new(name: "DC", capital: true)
