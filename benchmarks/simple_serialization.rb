# typed: strict
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "benchmark/ips"
require_relative "helpers"

game_schema = Typed::Schema.from_struct(BenchmarkHelpers::Game)
game_data = BenchmarkHelpers.game_data
game_struct = game_schema.from_hash(game_data).payload

hash_serializer = Typed::HashSerializer.new(schema: game_schema)
json_serializer = Typed::JSONSerializer.new(schema: game_schema)

Benchmark.ips do |x|
  x.report("simple hash serialization") do
    hash_serializer.serialize(game_struct)
  end

  x.report("simple json serialization") do
    json_serializer.serialize(game_struct)
  end

  x.compare!
end

