# typed: true

class StructExtTest < Minitest::Test
  def setup
    @person = Person.new(name: "Max", age: 29)
  end

  def test_create_schema_is_available
    assert_equal(PersonSchema, Person.create_schema)
  end

  def test_from_hash_works
    result = Person.from_hash({name: "Max", age: 29})

    assert_success(result)
    assert_payload(@person, result)
  end

  def test_from_json_works
    result = Person.from_json('{"name": "Max", "age": 29}')

    assert_success(result)
    assert_payload(@person, result)
  end

  def test_to_hash_works
    assert_equal({name: "Max", age: 29}, @person.to_hash)
  end

  def test_to_json_works
    assert_equal('{"name":"Max","age":29}', @person.to_json)
  end
end
