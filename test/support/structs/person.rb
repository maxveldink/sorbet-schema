# typed: true

require_relative "job"
require_relative "../enums/ruby_rank"
require_relative "../enums/diamond_rank"

class Person < T::Struct
  include ActsAsComparable

  const :name, String
  const :age, Integer
  const :stone_rank, T.any(RubyRank, DiamondRank)
  const :job, T.nilable(Job)
end

MAX_PERSON = Person.new(name: "Max", age: 29, stone_rank: RubyRank::Luminary)
ALEX_PERSON = Person.new(name: "Alex", age: 31, stone_rank: RubyRank::Brilliant, job: DEVELOPER_JOB)
