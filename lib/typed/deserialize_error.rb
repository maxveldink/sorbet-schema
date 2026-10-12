# typed: strict

module Typed
  class DeserializeError < SerializationError
    extend T::Sig

    sig { returns(T::Array[ValidationIssue]) }
    attr_reader :issues

    sig { params(message: T.nilable(String), issues: T.nilable(T::Array[ValidationIssue]), code: Symbol).void }
    def initialize(message = nil, issues: nil, code: :deserialization_failed)
      super(message)
      @issues = T.let(issues || [ValidationIssue.new(code: code, message: self.message)], T::Array[ValidationIssue])
    end

    sig { params(segment: ValidationIssue::PathSegment).returns(T.self_type) }
    def prepend_path(segment)
      copy = dup
      copy.issues = issues.map { |issue| issue.prepend(segment) }
      copy
    end

    sig { returns({error: String}) }
    def to_h
      {error: message}
    end

    sig { params(_options: T::Hash[T.untyped, T.untyped]).returns(String) }
    def to_json(_options = {})
      JSON.generate(to_h)
    end

    protected

    sig { params(issues: T::Array[ValidationIssue]).void }
    attr_writer :issues
  end
end
