# typed: true

class Person < T::Struct
  include ActsAsComparable

  const :name, String
  const :age, Integer
  const :job, T.nilable(Job)
end
