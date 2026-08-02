# typed: strict
# frozen_string_literal: true

require "minitest/autorun"
require "minitest/focus"
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]
require "minitest/result_assertions"

require "debug"

require "sorbet-schema"

module Kernel
  alias_method :require_allowing_test_blocklist, :require

  def require(name)
    raise LoadError, "cannot load such file -- #{name}" if Thread.current[:blocked_requires]&.include?(name)

    require_allowing_test_blocklist(name)
  end
end

Dir["test/support/**/*.rb"].each { |file| require file }
