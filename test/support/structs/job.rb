# typed: true

require "date"
require_relative "money"

class Job < T::Struct
  include ActsAsComparable

  const :title, String
  const :salary, Money
  const :start_date, T.nilable(Date)
  const :needs_credential, T::Boolean, default: false
end

JOB_SCHEMA_WITH_INLINE_SERIALIZER = Typed::Schema.new(
  target: Job,
  fields: [
    Typed::Field.new(name: :title, type: String),
    Typed::Field.new(name: :salary, type: Integer),
    Typed::Field.new(name: :start_date, type: T::Utils.coerce(T.nilable(Date)), inline_serializer: ->(start_date) { start_date.strftime("%j %B") })
  ]
)
DEVELOPER_JOB = Job.new(title: "Software Developer", salary: Money.new(cents: 90_000_00))
DEVELOPER_JOB_WITH_START_DATE = Job.new(title: "Software Developer", salary: Money.new(cents: 90_000_00), start_date: Date.new(2024, 3, 1))
