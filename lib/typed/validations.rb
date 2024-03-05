# typed: strict

module Typed
  module Validations
    ValidationResult = T.type_alias { Result[ValidatedValue, ValidationError] }
    ValidatedParams = T.type_alias { T::Hash[Symbol, Value] }
  end
end
