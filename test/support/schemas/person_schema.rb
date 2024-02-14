# typed: true

require_relative "../structs/person"

PersonSchema = Typed::Schema.new(
  fields: [
    Typed::Field.new(name: :name, type: String),
    Typed::Field.new(name: :age, type: Integer)
  ],
  target: Person
)
