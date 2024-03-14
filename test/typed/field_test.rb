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

  def test_when_standard_type_work_with_works
    assert(@required_field.works_with?("Max"))
    refute(@required_field.works_with?(1))
  end

  def test_when_simple_base_type_works_with_works
    field = Typed::Field.new(name: :bools, type: T::Utils.coerce(T::Boolean))

    assert(field.works_with?(true))
    assert(field.works_with?(false))
    refute(field.works_with?("Max"))
  end

  def test_when_recursive_base_type_works_with_works
    field = Typed::Field.new(name: :typed_array, type: T::Utils.coerce(T::Array[String]))

    assert(field.works_with?([]))
    assert(field.works_with?(["Max"]))
    refute(field.works_with?("Max"))
    refute(field.works_with?([1]))
    refute(field.works_with?([1, "Max"]))
  end
end
