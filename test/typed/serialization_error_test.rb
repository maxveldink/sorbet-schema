# typed: true

class DeserializeErrorTest < Minitest::Test
  def setup
    @error = Typed::DeserializeError.new("Testing")
  end

  def to_h_works
    assert_equal({error: "Testing"}, @error.to_h)
  end

  def to_json_works
    assert_equal('{"error":"Testing"}', @error.to_json)
  end
end
