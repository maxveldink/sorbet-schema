# typed: strict
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "benchmark/ips"
require_relative "helpers"

game_schema = Typed::Schema.from_struct(BenchmarkHelpers::Game)
game_data = BenchmarkHelpers.game_data
game_json = JSON.generate(game_data)

Benchmark.ips do |x|
  x.report("simple hash deserialization") do
    game_schema.from_hash(game_data)
  end

  x.report("simple json deserialization") do
    game_schema.from_json(game_json)
  end

  x.compare!
end
