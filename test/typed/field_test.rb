# typed: true

require "test_helper"

class FieldTest < Minitest::Test
  def setup
    @required_field = Typed::Field.new(name: :im_required, type: String)
    @optional_field = Typed::Field.new(name: :im_optional, type: String, required: false)
  end

  def test_initialize_takes_sorbet_types_and_built_in_types
    assert_equal(@required_field, Typed::Field.new(name: :im_required, type: T::Utils.coerce(String)))
  end

  def test_equality
    assert_equal(@required_field, Typed::Field.new(name: :im_required, type: String))
    refute_equal(@required_field, @optional_field)
  end

  def test_required_and_optional_helpers_work_when_required
    assert_predicate(@required_field, :required?)
    refute_predicate(@required_field, :optional?)
  end

  def test_required_and_optional_helpers_work_when_optional
    assert_predicate(@optional_field, :optional?)
    refute_predicate(@optional_field, :required?)
  end

  def test_when_inline_serializer_serialize_uses_it
    field = Typed::Field.new(name: :testing, type: String, inline_serializer: ->(_value) { "banana" })

    assert_equal("banana", field.serialize("testing"))
    assert_nil(field.serialize(nil))
  end

  def test_when_no_inline_serializer_serialize_returns_given_value
    assert_equal("testing", @required_field.serialize("testing"))
    assert_nil(@required_field.serialize(nil))
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
