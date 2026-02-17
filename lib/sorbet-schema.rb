# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require "sorbet-result"
require "sorbet-struct-comparable"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.inflector.inflect("json_serializer" => "JSONSerializer")
loader.ignore("#{__dir__}/sorbet-schema")
loader.setup

require_relative "sorbet-schema/version"
require_relative "sorbet-schema/hash_transformer"
require_relative "sorbet-schema/serialize_value"
require_relative "sorbet-schema/t/struct"

# Sorbet-aware namespace to super-charge your projects
module Typed
  Value = T.type_alias { T.untyped }
end