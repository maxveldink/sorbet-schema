# typed: strict

module Typed
  class RequiredFieldError < ValidationError
    extend T::Sig

    sig { params(field_name: Symbol).void }
    def initialize(field_name:)
      super("#{field_name} is required.")
    end
  end
end
