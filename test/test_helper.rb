# typed: strict
# frozen_string_literal: true

require "minitest/autorun"
require "minitest/focus"
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]
require "minitest/result_assertions"

require "debug"

require "sorbet-schema"
require "sorbet-schema/struct_ext"

Dir["test/support/structs/*.rb"].each { |file| require file }
