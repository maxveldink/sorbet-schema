# typed: true

class Job < T::Struct
  include T::Struct::ActsAsComparable

  const :title, String
  const :salary, Integer
end
