# typed: true

require "test_helper"

class JSONSchemaTest < Minitest::Test
  class Described < T::Struct
    const :title, String, extra: {description: "Shown to people"}
    const :published_on, T.nilable(Date)
    const :archived, T.nilable(T::Boolean)
    const :payload, T::Hash[String, T.anything], default: {}
    const :tags, T::Array[String], default: []
  end

  class Unsupported < T::Struct
    const :at, Time
  end

  def test_describes_scalars_nested_structs_and_enums
    expected = {
      "type" => "object",
      "properties" => {
        "title" => {"type" => "string"},
        "salary" => {
          "type" => "object",
          "properties" => {
            "cents" => {"type" => "integer"},
            "currency" => {"enum" => ["USD"], "type" => "string"}
          },
          "required" => ["cents"]
        },
        "start_date" => {"type" => ["string", "null"], "format" => "date"},
        "needs_credential" => {"type" => "boolean"}
      },
      "required" => ["title", "salary"]
    }

    assert_equal(expected, Job.schema.to_json_schema)
  end

  def test_describes_unions_and_nilable_structs
    properties = Person.schema.to_json_schema.fetch("properties")

    assert_equal(
      {"anyOf" => [
        {"enum" => ["rugged", "shiny", "pretty"], "type" => "string"},
        {"enum" => ["excellent", "good", "fair", "poor"], "type" => "string"}
      ]},
      properties.fetch("stone_rank")
    )
    assert_equal(Job.schema.to_json_schema.merge("type" => ["object", "null"]), properties.fetch("job"))
  end

  def test_describes_arrays_and_hashes
    properties = Country.schema.to_json_schema.fetch("properties")

    assert_equal({"type" => "array", "items" => City.schema.to_json_schema}, properties.fetch("cities"))
    assert_equal({"type" => "object", "additionalProperties" => {"type" => "string"}}, properties.fetch("national_items"))
    assert_equal(
      {"type" => ["object", "null"], "additionalProperties" => {"type" => "integer"}},
      City.schema.to_json_schema.dig("properties", "data")
    )
  end

  def test_describes_nested_immutable_structs
    properties = ImmutableCountry.schema.to_json_schema.fetch("properties")

    assert_equal({"type" => "array", "items" => ImmutableCity.schema.to_json_schema}, properties.fetch("cities"))
    assert_equal(
      {"type" => "object", "additionalProperties" => ImmutableCity.schema.to_json_schema},
      properties.fetch("cities_by_name")
    )
    assert_equal(
      ImmutableCity.schema.to_json_schema.merge("type" => ["object", "null"]),
      properties.fetch("capital")
    )
  end

  def test_keys_properties_by_serialized_name
    document = WebhookPayload.schema.to_json_schema

    assert_equal(["eventId", "emailAddress", "retries"], document.fetch("properties").keys)
    assert_equal(["eventId", "emailAddress"], document.fetch("required"))
  end

  def test_takes_description_and_nullability_from_props
    expected = {
      "type" => "object",
      "properties" => {
        "title" => {"type" => "string", "description" => "Shown to people"},
        "published_on" => {"type" => ["string", "null"], "format" => "date"},
        "archived" => {"type" => ["boolean", "null"]},
        "payload" => {"type" => "object"},
        "tags" => {"type" => "array", "items" => {"type" => "string"}}
      },
      "required" => ["title"]
    }

    assert_equal(expected, Described.schema.to_json_schema)
  end

  def test_resolves_nested_struct_schemas_through_the_given_proc
    without_currency = lambda do |struct|
      schema = struct.schema
      Typed::Schema.new(target: struct, fields: schema.fields.reject { |field| field.name == :currency })
    end

    document = Typed::JSONSchema.generate(Job.schema, struct_schema: without_currency)

    assert_equal(["cents"], document.dig("properties", "salary", "properties").keys)
  end

  def test_closes_every_struct_object_when_additional_properties_are_off
    document = Job.schema.to_json_schema(additional_properties: false)

    assert_equal(false, document.fetch("additionalProperties"))
    assert_equal(false, document.dig("properties", "salary", "additionalProperties"))
    assert_equal({"type" => "object"}, Described.schema.to_json_schema(additional_properties: false).dig("properties", "payload"))
  end

  def test_raises_on_types_without_json_form
    error = assert_raises(Typed::JSONSchema::UnsupportedTypeError) { Unsupported.schema.to_json_schema }

    assert_match("JSONSchemaTest::Unsupported.at", error.message)
  end
end
