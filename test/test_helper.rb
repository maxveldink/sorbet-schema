# typed: strict
# frozen_string_literal: true

require "minitest/autorun"
require "minitest/focus"
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

require "debug"

require "sorbet-schema"

require_relative "support/schemas/person_schema"
