# typed: true

class ImmutableCity < T::ImmutableStruct
  const :name, String
  const :capital, T::Boolean
  const :data, T.nilable(T::Hash[String, Integer])
end
