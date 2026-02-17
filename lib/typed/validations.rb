# typed: strict

module Typed
  module Validations
    ValidationResult = T.type_alias { Result[ValidatedValue, ValidationError] }
  end
end