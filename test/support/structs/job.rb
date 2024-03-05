# typed: true

class Job < T::Struct
  include ActsAsComparable

  const :title, String
  const :salary, Integer
end
