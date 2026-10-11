# typed: true

require_relative "city"
require_relative "immutable_city"

class ImmutableCountry < T::ImmutableStruct
  const :name, String
  const :cities, T::Array[ImmutableCity], default: []
  const :cities_by_name, T::Hash[String, ImmutableCity], default: {}
  const :capital, T.nilable(ImmutableCity)
  const :mutable_city, T.nilable(City)
end
