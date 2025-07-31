#!/usr/bin/env ruby
# typed: false
# frozen_string_literal: true

require "bundler/setup"
require "sorbet-schema"
require "benchmark"
require "date"
require "json"

require_relative "../test/support/enums/currency"
require_relative "../test/support/enums/ruby_rank"
require_relative "../test/support/enums/diamond_rank"
require_relative "../test/support/structs/money"
require_relative "../test/support/structs/job"
require_relative "../test/support/structs/person"

puts "==============================================="

# Number of iterations for the benchmark
iterations = 1000
puts "Running #{iterations} iterations for each serializer"

# Create test data for JSON serialization
json_data = {
  name: "John Doe",
  age: 35,
  stone_rank: "shiny", # RubyRank::Luminary
  job: {
    title: "Software Engineer",
    salary: {
      cents: 120000_00,
      currency: "USD"
    },
    start_date: "2023-01-15",
    needs_credential: true
  }
}.to_json

# Create string-keyed hash data to test with string keys
string_key_hash_data = {
  "name" => "John Doe",
  "age" => 35,
  "stone_rank" => RubyRank::Luminary,
  "job" => {
    "title" => "Software Engineer",
    "salary" => {
      "cents" => 120000_00,
      "currency" => Currency::USD
    },
    "start_date" => Date.new(2023, 1, 15),
    "needs_credential" => true
  }
}

# Verify that both serializers work correctly with the test data
puts "\nVerifying serializers work correctly with test data..."

json_serializer = Typed::JSONSerializer.new(schema: Person.schema)
json_result = json_serializer.deserialize(json_data)

if json_result.success?
  puts "✓ JSON serializer works correctly"
else
  puts "✗ JSON serializer failed: #{json_result.error.message}"
  exit 1
end

hash_serializer = Typed::HashSerializer.new(schema: Person.schema)
string_hash_result = hash_serializer.deserialize(string_key_hash_data)

if string_hash_result.success?
  puts "✓ Hash serializer works correctly with string keys"
else
  puts "✗ Hash serializer failed with string keys: #{string_hash_result.error.message}"
  exit 1
end

# Benchmark JSON serializer
puts "\nBenchmarking JSON serializer..."
json_time = Benchmark.measure do
  json_serializer = Typed::JSONSerializer.new(schema: Person.schema)
  iterations.times do
    json_serializer.deserialize(json_data)
  end
end

# Benchmark Hash serializer with symbol keys
puts "Benchmarking Hash serializer..."
hash_time = Benchmark.measure do
  hash_serializer = Typed::HashSerializer.new(schema: Person.schema)
  iterations.times do
    hash_serializer.deserialize(string_key_hash_data)
  end
end

puts "\nResults:"
puts "========"
puts "JSON serializer: #{json_time.real.round(4)} seconds (#{(json_time.real / iterations * 1000).round(4)} ms per call)"
puts "Hash serializer: #{hash_time.real.round(4)} seconds (#{(hash_time.real / iterations * 1000).round(4)} ms per call)"
puts "\nAnalysis:"
puts "========="
puts "This benchmark compares the performance of deserializing the same data structure using"
puts "The results show the relative performance differences between these approaches and can"
puts "help identify which serializer is more efficient for different use cases."
