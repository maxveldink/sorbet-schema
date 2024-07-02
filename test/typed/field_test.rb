# typed: true

require "test_helper"

class FieldTest < Minitest::Test
  def test_sets_values_correctly_for_required
    field = Typed::Field.new(name: :required, type: String)

    assert_equal(:required, field.name)
    assert_equal(T::Utils.coerce(String), field.type)
    assert(field.required)
    assert_nil(field.default)
    assert_nil(field.inline_serializer)
  end

  def test_sets_values_correctly_for_default
    field = Typed::Field.new(name: :with_default, type: String, default: "fallback")

    assert_equal(:with_default, field.name)
    assert_equal(T::Utils.coerce(String), field.type)
    refute(field.required)
    assert_equal("fallback", field.default)
    assert_nil(field.inline_serializer)
  end

  def test_sets_values_correctly_for_nilable_type
    field = Typed::Field.new(name: :nilable_type, type: T::Utils.coerce(T.nilable(String)))

    assert_equal(:nilable_type, field.name)
    assert_equal(T::Utils.coerce(String), field.type)
    refute(field.required)
    assert_nil(field.default)
    assert_nil(field.inline_serializer)
  end

  def test_sets_values_correctly_for_nilable_type_with_default
    field = Typed::Field.new(name: :nilable_type, type: T::Utils.coerce(T.nilable(String)), default: "fallback")

    assert_equal(:nilable_type, field.name)
    assert_equal(T::Utils.coerce(String), field.type)
    refute(field.required)
    assert_equal("fallback", field.default)
    assert_nil(field.inline_serializer)
  end

  def test_sets_values_correctly_for_optional
    field = Typed::Field.new(name: :optional, type: String, optional: true)

    assert_equal(:optional, field.name)
    assert_equal(T::Utils.coerce(String), field.type)
    refute(field.required)
    assert_nil(field.default)
    assert_nil(field.inline_serializer)
  end

  def test_sets_values_correctly_for_optional_with_default
    field = Typed::Field.new(name: :optional, type: String, default: "fallback")

    assert_equal(:optional, field.name)
    assert_equal(T::Utils.coerce(String), field.type)
    refute(field.required)
    assert_equal("fallback", field.default)
    assert_nil(field.inline_serializer)
  end

  def test_sets_values_with_inline_serializer
    field = Typed::Field.new(name: :inline, type: String, inline_serializer: ->(_value) { "banana" })

    assert_equal(:inline, field.name)
    assert_equal(T::Utils.coerce(String), field.type)
    assert(field.required)
    assert_nil(field.default)
    refute_nil(field.inline_serializer)
  end

  def test_initialize_raises_argument_error_with_invalid_default_value
    error = assert_raises(ArgumentError) { Typed::Field.new(name: :fallback, type: String, default: 1) }

    assert_equal("Given 1 with class of Integer for default, invalid with type String", error.message)
  end

  def test_equality
    inline_serializer = ->(_value) { "banana" }
    assert_equal(
      Typed::Field.new(name: :inline, type: String, optional: true, default: "testing", inline_serializer:),
      Typed::Field.new(name: :inline, type: String, optional: true, default: "testing", inline_serializer:)
    )
  end

  def test_required_and_optional_helpers_work_when_required
    field = Typed::Field.new(name: :required, type: String)

    assert_predicate(field, :required?)
    refute_predicate(field, :optional?)
  end

  def test_required_and_optional_helpers_work_when_optional
    field = Typed::Field.new(name: :optional, type: String, optional: true)

    assert_predicate(field, :optional?)
    refute_predicate(field, :required?)
  end

  def test_when_inline_serializer_serialize_uses_it
    field = Typed::Field.new(name: :testing, type: String, inline_serializer: ->(_value) { "banana" })

    assert_equal("banana", field.serialize("testing"))
    assert_nil(field.serialize(nil))
  end

  def test_when_no_inline_serializer_serialize_returns_given_value
    field = Typed::Field.new(name: :testing, type: String)

    assert_equal("testing", field.serialize("testing"))
    assert_nil(field.serialize(nil))
  end

  def test_when_standard_type_work_with_works
    field = Typed::Field.new(name: :testing, type: String)

    assert(field.works_with?("Max"))
    refute(field.works_with?(1))
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
