# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in sorbet-schema.gemspec
gemspec

group :development do
  gem "rake"
  gem "standard"
  gem "standard-performance"
  gem "standard-sorbet"
  gem "sorbet"
  gem "tapioca", require: false
end

group :development, :test do
  gem "minitest"
  gem "minitest-focus"
  gem "minitest-reporters"

  gem "debug"

  gem "sorbet-struct-comparable"
end
