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
loader.ignore("#{__dir__}/sorbet-schema/**/*.rb")
loader.inflector.inflect(
  "json_serializer" => "JSONSerializer"
)
loader.setup

# We don't want to place these in the `Typed` module.
# `sorbet-schema` is a directory that is not autoloaded
# but contains extensions, so we need to manually require it.
require_relative "sorbet-schema/hash_transformer"
require_relative "sorbet-schema/serialize_value"

# We want to add a default `schema` method to structs
# that will guarentee a schema can be created for use
# with serialization. This can (and should) be overridden
# in child struct classes.
require_relative "sorbet-schema/t/struct"

# Sorbet-aware namespace to super-charge your projects
module Typed
  Value = T.type_alias { T.untyped }
end
