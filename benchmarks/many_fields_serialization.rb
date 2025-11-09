# typed: strict
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "benchmark/ips"
require_relative "helpers"

humongous_schema = Typed::Schema.from_struct(BenchmarkHelpers::Humongous)
humongous_data = BenchmarkHelpers.humongous_data
humongous_struct = humongous_schema.from_hash(humongous_data).payload

hash_serializer = Typed::HashSerializer.new(schema: humongous_schema)
json_serializer = Typed::JSONSerializer.new(schema: humongous_schema)

Benchmark.ips do |x|
  x.report("hash serialization with many fields") do
    hash_serializer.serialize(humongous_struct)
  end

  x.report("json serialization with many fields") do
    json_serializer.serialize(humongous_struct)
  end

  x.compare!
end
