# typed: true

module Typed
  class JSONSerializerTest < Minitest::Test
    def setup
      @serializer = JSONSerializer.new
    end

    def test_it_can_serialize
      max = Person.new(name: "Max", age: 29)

      assert_equal('{"name" => "Max", "age" => 29}', @serializer.serialize(max))
    end
  end
end
