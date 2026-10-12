# typed: strict

module Typed
  module Validations
    class ValidationError < DeserializeError
      sig { params(message: T.nilable(String), issues: T.nilable(T::Array[ValidationIssue]), code: Symbol).void }
      def initialize(message = nil, issues: nil, code: :validation_failed)
        super
      end
    end
  end
end
