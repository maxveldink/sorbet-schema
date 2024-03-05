# typed: strict

module Typed
  module Coercion
    class StructCoercer
      extend T::Sig
      extend T::Generic

      extend Coercer

      Target = type_template { {fixed: T::Struct} }

      sig { override.params(field: Field, value: Value).returns(Result[Target, CoercionError]) }
      def self.coerce(field:, value:)
        type = field.type

        return Failure.new(CoercionError.new("Field type must inherit from T::Struct for Struct coercion.")) unless type < T::Struct
        return Failure.new(CoercionError.new("Value must be a Hash for Struct coercion.")) unless value.is_a?(Hash)

        Success.new(type.from_hash!(HashTransformer.new.deep_stringify_keys(value)))
      rescue ArgumentError => e
        Failure.new(CoercionError.new(e.message))
      end
    end
  end
end
