# typed: true

require "test_helper"
require "msgpack"

class ValidationIssuesTest < Minitest::Test
  class Address < T::Struct
    const :zip, Integer
  end

  class Contact < T::Struct
    const :address, Address
    const :scores, T::Array[Integer]
  end

  class RenamedAddress < T::ImmutableStruct
    const :zip, Integer, name: "postalCode"
  end

  class Directory < T::ImmutableStruct
    const :addresses, T::Array[RenamedAddress], name: "mailingAddresses"
    const :by_name, T::Hash[String, RenamedAddress], name: "byName"
  end

  class UnionInput < T::Struct
    const :value, T.any(Integer, Date)
  end

  class CollectionUnionInput < T::Struct
    const :value, T.any(T::Array[Integer], Integer)
  end

  class HashInput < T::Struct
    const :values, T::Hash[Integer, Integer]
  end

  class UnsupportedInput < T::Struct
    const :value, BigDecimal
  end

  class DecimalArrayInput < T::Struct
    const :values, T::Array[BigDecimal]
  end

  class CustomDecimalCoercer < Typed::Coercion::Coercer
    Target = type_member { {fixed: BigDecimal} }

    sig { override.params(type: T::Types::Base).returns(T::Boolean) }
    def self.used_for_type?(type)
      type == T::Utils.coerce(BigDecimal)
    end

    sig { override.params(type: T::Types::Base, value: Typed::Value).returns(Typed::Result[BigDecimal, Typed::Coercion::CoercionError]) }
    def coerce(type:, value:)
      Typed::Failure.new(Typed::Coercion::CoercionError.new(
        "Invalid decimal.",
        issues: [Typed::ValidationIssue.new(path: ["digits"], code: :invalid_decimal, message: "Invalid digits.")]
      ))
    end
  end

  def test_issue_example_preserves_legacy_summary
    result = Contact.deserialize_from(:json, '{"address":{"zip":"oops"},"scores":[1,2]}')

    assert_failure(result)
    error = result.error
    assert_equal("'oops' cannot be coerced into Integer.", error.message)
    assert_equal({error: error.message}, error.to_h)
    assert_equal('{"error":"\'oops\' cannot be coerced into Integer."}', error.to_json)
    assert_equal([
      {path: ["address", "zip"], code: :coercion_failed, message: error.message}
    ], error.issues.map(&:to_h))
  end

  def test_multiple_fields_and_array_elements_keep_every_issue_and_original_index
    result = Contact.deserialize_from(:hash, {address: {}, scores: [1, "bad", 3, "worse"]})

    assert_failure(result)
    assert_instance_of(Typed::Validations::MultipleValidationError, result.error)
    assert_equal([["address", "zip"], ["scores", 1], ["scores", 3]], result.error.issues.map(&:path))
    assert_equal([:required_field, :coercion_failed, :coercion_failed], result.error.issues.map(&:code))
    assert_equal("Multiple validation errors found: zip is required. | 'bad' cannot be coerced into Integer. | 'worse' cannot be coerced into Integer.", result.error.message)
    assert_equal(2, T.cast(result.error, Typed::Validations::MultipleValidationError).errors.length)
  end

  def test_nested_immutable_structs_and_hash_values_use_input_keys_in_all_nested_formats
    input = {"mailingAddresses" => [{"postalCode" => "bad"}, {}], "byName" => {"home" => {"postalCode" => "worse"}}}
    sources = {
      hash: input,
      json: JSON.generate(input),
      yml: YAML.dump(input),
      msgpack: MessagePack.pack(input)
    }

    sources.each do |format, source|
      result = Directory.deserialize_from(format, source)
      assert_failure(result)
      assert_equal([
        ["mailingAddresses", 0, "postalCode"],
        ["mailingAddresses", 1, "postalCode"],
        ["byName", "home", "postalCode"]
      ], result.error.issues.map(&:path), format.to_s)
      assert_equal([:coercion_failed, :required_field, :coercion_failed], result.error.issues.map(&:code))
    end
  end

  def test_hash_key_and_value_failures_keep_original_keys
    result = HashInput.deserialize_from(:hash, {values: {"bad-key" => "bad-value", 7 => "also-bad"}})

    assert_failure(result)
    assert_equal([["values", "bad-key"], ["values", "bad-key"], ["values", 7]], result.error.issues.map(&:path))
    assert_equal([
      "'bad-key' cannot be coerced into Integer.",
      "'bad-value' cannot be coerced into Integer.",
      "'also-bad' cannot be coerced into Integer."
    ], result.error.issues.map(&:message))
  end

  def test_failed_union_keeps_issues_from_each_alternative
    result = UnionInput.deserialize_from(:hash, {value: "oops"})

    assert_failure(result)
    assert_equal([["value"], ["value"]], result.error.issues.map(&:path))
    assert_equal([:coercion_failed, :coercion_failed], result.error.issues.map(&:code))
    assert_equal("'oops' cannot be coerced into Integer., 'oops' cannot be coerced into Date.", result.error.message)
  end

  def test_collection_union_keeps_nested_paths
    result = CollectionUnionInput.deserialize_from(:hash, {value: [1, "oops"]})

    assert_failure(result)
    assert_equal([["value", 1], ["value"]], result.error.issues.map(&:path))
  end

  def test_successful_union_does_not_return_failed_alternative_issues
    result = UnionInput.deserialize_from(:hash, {value: "2024-01-01"})

    assert_success(result)
    assert_equal(Date.new(2024, 1, 1), result.payload.value)
  end

  def test_missing_coercer_has_a_stable_code
    result = UnsupportedInput.deserialize_from(:hash, {value: "1.5"})

    assert_failure(result)
    assert_equal([["value"]], result.error.issues.map(&:path))
    assert_equal([:coercion_not_supported], result.error.issues.map(&:code))
    assert_equal("Coercer not found for type BigDecimal.", result.error.message)
  end

  def test_custom_coercer_issues_survive_collection_and_field_wrapping
    Typed::Coercion.register_coercer(CustomDecimalCoercer)
    result = DecimalArrayInput.deserialize_from(:hash, {values: ["bad", "worse"]})

    assert_failure(result)
    assert_equal([["values", 0, "digits"], ["values", 1, "digits"]], result.error.issues.map(&:path))
    assert_equal([:invalid_decimal, :invalid_decimal], result.error.issues.map(&:code))
    assert_equal(["Invalid digits.", "Invalid digits."], result.error.issues.map(&:message))
    assert_equal("Invalid decimal. | Invalid decimal.", result.error.message)
  ensure
    Typed::Coercion::CoercerRegistry.instance.reset!
  end

  def test_general_errors_provide_one_root_issue
    errors = [
      [Typed::DeserializeError.new("Cannot deserialize."), :deserialization_failed],
      [Typed::Validations::ValidationError.new("Invalid value."), :validation_failed],
      [Typed::Coercion::CoercionError.new("Cannot coerce."), :coercion_failed]
    ]

    errors.each do |error, code|
      assert_equal([{path: [], code: code, message: error.message}], error.issues.map(&:to_h))
    end
  end

  def test_parse_errors_have_a_root_issue_and_unchanged_summary
    result = Contact.deserialize_from(:json, "null")

    assert_failure(result)
    assert_instance_of(Typed::ParseError, result.error)
    assert_equal([{path: [], code: :parse_error, message: "json could not be parsed. Check for typos."}], result.error.issues.map(&:to_h))
    assert_equal('{"error":"json could not be parsed. Check for typos."}', result.error.to_json)
  end

  def test_error_path_prefixing_preserves_subclass_and_does_not_mutate_original
    original = Typed::Validations::RequiredFieldError.new(field_name: :zip)
    prefixed = original.prepend_path("postalCode").prepend_path("address")

    assert_instance_of(Typed::Validations::RequiredFieldError, prefixed)
    assert_equal([], T.must(original.issues.first).path)
    assert_equal(["address", "postalCode"], T.must(prefixed.issues.first).path)
    assert_equal(original.message, prefixed.message)
  end

  def test_direct_type_validation_exposes_type_mismatch_code
    result = Typed::Field.new(name: :zip, type: Integer).validate("oops")

    assert_failure(result)
    assert_instance_of(Typed::Validations::TypeMismatchError, result.error)
    assert_equal([:type_mismatch], result.error.issues.map(&:code))
    assert_equal("Invalid type given to zip. Expected Integer, got String.", result.error.message)
  end

  def test_csv_required_field_paths_use_serialized_names
    result = RenamedAddress.deserialize_from(:csv, "postalCode\n\"\"\n")

    assert_failure(result)
    assert_equal([["postalCode"]], result.error.issues.map(&:path))
  end

  def test_active_record_errors_preserve_nested_association_paths_and_sibling_failures
    country = CountryModel.new
    location = LocationModel.new(name: "Florida", country: country)
    user = UserModel.new(age: 28, location: location)
    serializer = Typed::ActiveRecordSerializer.new(schema: ARUser.schema, model_class: UserModel)

    result = serializer.deserialize(user)

    assert_failure(result)
    assert_equal([["name"], ["location", "country", "name"]], result.error.issues.map(&:path))
    assert_equal([:required_field, :required_field], result.error.issues.map(&:code))
  end

  def test_issue_collection_is_statically_typed
    result = Contact.deserialize_from(:hash, {})
    issues = T.assert_type!(result.error.issues, T::Array[Typed::ValidationIssue])
    path = T.assert_type!(T.must(issues.first).path, T::Array[T.any(String, Integer)])

    assert_equal(["address"], path)
  end
end
