# typed: true
# frozen_string_literal: true

module GemUnavailableHelper
  def with_gem_unavailable(gem_name, const_name)
    original_const = Object.send(:remove_const, const_name) if Object.const_defined?(const_name)
    (Thread.current[:blocked_requires] ||= []) << gem_name

    yield
  ensure
    Thread.current[:blocked_requires]&.delete(gem_name)
    Object.const_set(const_name, original_const) if original_const
  end
end

module Minitest
  class Test
    include GemUnavailableHelper
  end
end
