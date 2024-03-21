# typed: true

require "date"

class Job < T::Struct
  include ActsAsComparable

  const :title, String
  const :salary, Integer
  const :start_date, T.nilable(Date)
end

DEVELOPER_JOB = Job.new(title: "Software Developer", salary: 90_000_00)
DEVELOPER_JOB_WITH_START_DATE = Job.new(title: "Software Developer", salary: 90_000_00, start_date: Date.new(2024, 3, 1))
