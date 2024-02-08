# typed: true

require "test_helper"

class JSONSerializerTest < Minitest::Test
  def setup
    @serializer = Typed::JSONSerializer.new(
      schema: Typed::Schema.new(target: Person)
    )
  end

  def test_it_can_simple_serialize
    max = Person.new(name: "Max", age: 29)

    assert_equal('{"name":"Max","age":29}', @serializer.serialize(max))
  end

  def test_it_can_simple_deserialize
    max_json = '{"name": "Max", "age": 29}'

    assert_equal(Person.new(name: "Max", age: 29), @serializer.deserialize(max_json))
  end

  def test_it_can_tell_you_validation_errors_on_deserialize
    max_json = '{"name": "Max"}'

    assert_equal(Typed::Failure.new(ValidationError.new("Missing required field 'age'.")), @serializer.deserialize(max_json))
  end
end
