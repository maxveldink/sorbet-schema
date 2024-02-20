# typed: strict

module Typed
  module Validations
    module FieldValidator
      extend T::Sig
      extend T::Helpers
      interface!

      sig { abstract.params(field: Field, value: Value).returns(ValidationResult) }
      def validate(field:, value:)
      end
    end
  end
end
