# typed: strict

module Typed
  module Validations
    class TypeMismatchError < ValidationError
      extend T::Sig

      sig { params(field_name: Symbol, field_type: T::Class[T.anything], given_type: T::Class[T.anything]).void }
      def initialize(field_name:, field_type:, given_type:)
        super("Invalid type given to #{field_name}. Expected #{field_type}, got #{given_type}.")
      end
    end
  end
end
