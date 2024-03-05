# typed: strict

module Typed
  module Validations
    ValidationResult = T.type_alias { Result[Value, ValidationError] }
  end
end
