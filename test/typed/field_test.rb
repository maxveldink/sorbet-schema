# typed: true

require "test_helper"

class FieldTest < Minitest::Test
  def setup
    @required_field = Typed::Field.new(name: :im_required, type: String)
    @optional_field = Typed::Field.new(name: :im_optional, type: String, required: false)
  end

  def test_required_and_optional_helpers_work_when_required
    assert_predicate(@required_field, :required?)
    refute_predicate(@required_field, :optional?)
  end

  def test_required_and_optional_helpers_work_when_optional
    assert_predicate(@optional_field, :optional?)
    refute_predicate(@optional_field, :required?)
  end
end
