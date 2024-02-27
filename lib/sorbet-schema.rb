# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require "sorbet-result"
require "sorbet-struct-comparable"

# We can't use `Loader.for_gem` here as we've unconventionally named the root file.
require "zeitwerk"
loader = Zeitwerk::Loader.new
loader.push_dir(__dir__.to_s)
loader.ignore(__FILE__)
loader.ignore("#{__dir__}/sorbet-schema/version.rb")
loader.inflector.inflect(
  "json_serializer" => "JSONSerializer"
)
loader.setup

# Sorbet-aware namespace to super-charge your projects
module Typed; end
