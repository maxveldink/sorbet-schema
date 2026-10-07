# typed: strict

require "test_helper"

# Proves the fix for https://github.com/maxveldink/sorbet-schema/issues/89:
# every deserialize entry point below returns a `Typed::Result` narrowed to
# the concrete struct type, so `.and_then` can call struct-specific methods
# (e.g. `#name`) with no `T.cast`. If narrowing regressed to `T::Struct` or
# `T.untyped` was inferred instead of `City`, this file would fail
# `bundle exec srb tc` (calling `#name` on `T::Struct` does not typecheck).
class NarrowingTest < Minitest::Test
  extend T::Sig

  sig { void }
  def test_deserialize_from_narrows_with_no_cast
    name = City.deserialize_from(:hash, {name: "New York", capital: false}).and_then { |city| Typed::Success.new(city.name) }

    assert_payload("New York", name)
  end

  sig { void }
  def test_serializer_deserialize_narrows_with_no_cast
    name = City.serializer(:hash).deserialize({name: "New York", capital: false}).and_then { |city| Typed::Success.new(city.name) }

    assert_payload("New York", name)
  end

  sig { void }
  def test_schema_from_hash_narrows_with_no_cast
    name = City.schema.from_hash({name: "New York", capital: false}).and_then { |city| Typed::Success.new(city.name) }

    assert_payload("New York", name)
  end

  sig { void }
  def test_direct_serializer_construction_narrows_with_no_cast
    schema = City.schema
    name = Typed::HashSerializer.new(schema: schema).deserialize({name: "New York", capital: false}).and_then { |city| Typed::Success.new(city.name) }

    assert_payload("New York", name)
  end

  sig { void }
  def test_schema_from_struct_narrows_with_no_cast
    name = Typed::Schema.from_struct(City).from_hash({name: "New York", capital: false}).and_then { |city| Typed::Success.new(city.name) }

    assert_payload("New York", name)
  end
end
