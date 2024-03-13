# typed: true

require_relative "job"
require_relative "../enums/ruby_rank"

class Person < T::Struct
  include ActsAsComparable

  const :name, String
  const :age, Integer
  const :ruby_rank, RubyRank
  const :job, T.nilable(Job)
end

MAX_PERSON = Person.new(name: "Max", age: 29, ruby_rank: RubyRank::Luminary)
ALEX_PERSON = Person.new(name: "Alex", age: 31, ruby_rank: RubyRank::Brilliant, job: Job.new(title: "Software Developer", salary: 1_000_000_00))
