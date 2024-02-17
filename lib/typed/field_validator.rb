# typed: strict

module Typed
  module FieldValidator
    extend T::Sig
    extend T::Helpers
    interface!

    Value = T.type_alias { T.untyped }
    ValidationResult = T.type_alias { Result[Value, ValidationError] }

    sig { abstract.params(field: Field, value: Value).returns(ValidationResult) }
    def validate(field:, value:)
    end
  end
end
