# typed: true

class StructCoercerTest < Minitest::Test
  def setup
    @coercer = Typed::Coercion::StructCoercer.new
    @type = T::Utils.coerce(Job)
    @type_with_nested_struct = T::Utils.coerce(Person)
  end

  def test_used_for_type_works
    assert(@coercer.used_for_type?(@type))
    refute(@coercer.used_for_type?(T::Utils.coerce(T::Struct)))
    refute(@coercer.used_for_type?(T::Utils.coerce(Integer)))
  end

  def test_when_non_struct_type_given_returns_failure
    result = @coercer.coerce(type: T::Utils.coerce(Integer), value: {})

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Field type must inherit from T::Struct for Struct coercion."), result)
  end

  def test_when_struct_of_correct_type_given_returns_success
    result = @coercer.coerce(type: @type, value: DEVELOPER_JOB)

    assert_success(result)
    assert_payload(DEVELOPER_JOB, result)
  end

  def test_when_struct_of_incorrect_type_given_returns_failure
    result = @coercer.coerce(type: @type, value: Country.new(name: "Canada", cities: [], national_items: {}))

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Value of type 'Country' cannot be coerced to Job Struct."), result)
  end

  def test_when_struct_can_be_coerced_returns_success
    result = @coercer.coerce(type: @type, value: {"title" => "Software Developer", :salary => Money.new(cents: 90_000_00)})

    assert_success(result)
    assert_payload(DEVELOPER_JOB, result)
  end

  def test_when_value_is_not_a_hash_returns_failure
    result = @coercer.coerce(type: @type, value: "bad")

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Value of type 'String' cannot be coerced to Job Struct."), result)
  end

  def test_when_struct_cannot_be_coerced_returns_failure
    result = @coercer.coerce(type: @type, value: {"not" => "valid"})

    assert_failure(result)
    assert_error(Typed::Coercion::CoercionError.new("Multiple validation errors found: title is required. | salary is required."), result)
  end

  def test_when_struct_has_nested_struct_and_all_values_passed_for_nested_struct
    name = "Alex"
    age = 31
    stone_rank = "pretty"
    salary = Money.new(cents: 90_000_00)
    title = "Software Developer"
    start_date = Date.new(2024, 3, 1)

    result = @coercer.coerce(type: @type_with_nested_struct, value: {name:, age:, stone_rank:, job: {title:, salary:, start_date:}})

    person = Person.new(
      name:,
      age:,
      stone_rank: RubyRank.deserialize(stone_rank),
      job: Job.new(title:, salary:, start_date:)
    )

    assert_success(result)
    assert_payload(person, result)
  end

  def test_when_struct_has_nested_struct_and_optional_start_date_not_passed_for_nested_struct
    name = "Alex"
    age = 31
    stone_rank = "pretty"
    salary = Money.new(cents: 90_000_00)
    title = "Software Developer"

    result = @coercer.coerce(type: @type_with_nested_struct, value: {name:, age:, stone_rank:, job: {title:, salary:}})

    person = Person.new(
      name:,
      age:,
      stone_rank: RubyRank.deserialize(stone_rank),
      job: Job.new(title:, salary:)
    )

    assert_success(result)
    assert_payload(person, result)
  end
end
