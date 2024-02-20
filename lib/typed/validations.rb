# typed: strict

module Typed
  module Validations
    Value = T.type_alias { T.untyped }
    ValidationResult = T.type_alias { Result[Value, ValidationError] }
  end
end
