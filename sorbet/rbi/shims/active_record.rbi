# typed: true

# Minimal shim for ActiveRecord so Sorbet can resolve the constant.
# ActiveRecord is an optional dependency — only loaded at runtime when present.
module ActiveRecord
  class AssociationTypeMismatch < StandardError; end
  class Rollback < StandardError; end

  class Base
    def initialize(**kwargs); end
    def attributes; end

    class << self
      def table_name=(name); end
      def column_names; end
      def configurations; end
      def establish_connection(*args); end
      def reflect_on_all_associations(*args); end
      def has_many(*args, **kwargs); end
      def belongs_to(*args, **kwargs); end
      def transaction(*args, &block); end
      def create!(*args, **kwargs); end
      def all; end
      def includes(*args); end
    end
  end

  class Schema
    def self.define(&block); end
  end

  module DatabaseConfigurations
    class HashConfig
      def initialize(*args); end
    end
  end
end
