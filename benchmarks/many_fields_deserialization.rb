# typed: strict
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "benchmark/ips"
require_relative "helpers"

humongous_schema = Typed::Schema.from_struct(BenchmarkHelpers::Humongous)
humongous_data = BenchmarkHelpers.humongous_data
humongous_json = JSON.generate(humongous_data)

Benchmark.ips do |x|
  x.report("hash deserialization with many fields") do
    humongous_schema.from_hash(humongous_data)
  end

  x.report("json deserialization with many fields") do
    humongous_schema.from_json(humongous_json)
  end

  x.compare!
end
