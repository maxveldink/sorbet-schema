# typed: true

# Minimal shim for ActiveSupport so Sorbet can resolve the constant.
# ActiveSupport is an optional dependency — only loaded at runtime when present (via ActiveRecord).
module ActiveSupport
  module Notifications
    def self.subscribed(callback, *args, &block); end
  end
end
