# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in sorbet-schema.gemspec
gemspec

group :development do
  gem "benchmark-ips"
  gem "rake"
  gem "standard"
  gem "standard-performance"
  gem "standard-sorbet"
  gem "sorbet"
  gem "tapioca", require: false
end

group :development, :test do
  gem "bigdecimal" # used for testing un-matched coercer
  gem "minitest"
  gem "minitest-focus"
  gem "minitest-reporters"

  gem "debug"

  gem "sorbet-struct-comparable"
end
