# typed: true

require "test_helper"
require "msgpack"

class SchemaTest < Minitest::Test
  class Profile < T::Struct
    include ActsAsComparable

    const :nickname, T.nilable(String), default: "guest", name: "displayName", extra: {description: "Public name"}
  end

  def setup
    @schema = Typed::Schema.new(
      fields: [
        Typed::Field.new(name: :name, type: String),
        Typed::Field.new(name: :age, type: Integer),
        Typed::Field.new(name: :stone_rank, type: T::Utils.coerce(T.any(RubyRank, DiamondRank))),
        Typed::Field.new(name: :job, type: Job, optional: true)
      ],
      target: Person
    )
  end

  def test_from_struct_returns_schema
    assert_equal(@schema, Typed::Schema.from_struct(Person))
  end

  def test_from_struct_takes_serialized_name_from_prop_name_option
    schema = Typed::Schema.from_struct(WebhookPayload)

    assert_equal([:event_id, :email_address, :retries], schema.fields.map(&:name))
    assert_equal([:eventId, :emailAddress, :retries], schema.fields.map(&:serialized_name))
  end

  def test_from_hash_create_struct
    result = @schema.from_hash({name: "Max", age: 29, stone_rank: RubyRank::Luminary})

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_from_json_creates_struct
    result = @schema.from_json('{"name": "Max", "age": 29, "stone_rank": "shiny"}')

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_from_csv_creates_struct
    result = @schema.from_csv("name,age,stone_rank\nMax,29,shiny\n")

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_from_yml_creates_struct
    result = @schema.from_yml("name: Max\nage: 29\nstone_rank: shiny\n")

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_from_msgpack_creates_struct
    result = @schema.from_msgpack(MessagePack.pack({"name" => "Max", "age" => 29, "stone_rank" => "shiny"}))

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_add_serializer_when_no_matching_field_returns_same_schema
    schema = @schema.add_serializer(:not_here, ->(value) { value + "a" })

    assert_equal(@schema, schema)
  end

  def test_add_serializer_when_matching_field_returns_schema_with_serializer
    schema = @schema.add_serializer(:name, ->(value) { value + "a" })

    refute_equal(@schema, schema)
  end

  def test_add_serializer_on_optional_field_keeps_field_optional
    schema = @schema.add_serializer(:job, ->(value) { value })

    result = schema.from_hash({name: "Max", age: 29, stone_rank: RubyRank::Luminary})

    assert_success(result)
    assert_payload(MAX_PERSON, result)
  end

  def test_add_serializer_preserves_field_metadata
    original = Profile.schema
    schema = original.add_serializer(:nickname, ->(value) { value.upcase })

    assert_equal(original.to_json_schema, schema.to_json_schema)
    assert(T.must(schema.fields.first).nilable)
    assert(T.must(schema.fields.first).optional?)
    assert_payload(Profile.new(nickname: "guest"), schema.from_hash({}))
    assert_payload(Profile.new(nickname: "Ada"), schema.from_hash({displayName: "Ada"}))
    assert_payload('{"displayName":"ADA"}', Typed::JSONSerializer.new(schema:).serialize(Profile.new(nickname: "Ada")))
  end

  # Guards against a regression where `const :target, T::Class[StructT]`
  # (rather than `T.all(T::Class[StructT], T.class_of(T::Struct))`) erases to
  # `T::Class[T.untyped]` at runtime and silently accepts a non-struct class.
  def test_target_rejects_non_struct_class_at_runtime
    assert_raises(TypeError) { Typed::Schema.new(target: T.unsafe(Integer), fields: []) }
  end
end
