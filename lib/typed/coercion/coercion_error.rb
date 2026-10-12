# typed: strict

module Typed
  module Coercion
    class CoercionError < StandardError
      extend T::Sig

      sig { returns(T::Array[ValidationIssue]) }
      attr_reader :issues

      sig { params(message: T.nilable(String), issues: T.nilable(T::Array[ValidationIssue]), code: Symbol).void }
      def initialize(message = nil, issues: nil, code: :coercion_failed)
        super(message)
        @issues = T.let(issues || [ValidationIssue.new(code: code, message: self.message)], T::Array[ValidationIssue])
      end
    end
  end
end
