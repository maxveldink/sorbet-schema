# typed: strict

module Typed
  module Coercion
    class TypedHashCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: T::Hash[T.untyped, T.untyped]} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def self.used_for_type?(type)
        type.is_a?(T::Types::TypedHash)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Field type must be a T::Hash.")) unless self.class.used_for_type?(type)
        return Failure.new(CoercionError.new("Value must be a Hash.")) unless value.is_a?(Hash)

        return Success.new(value) if type.recursively_valid?(value)

        key_and_value_types = T.cast(T.cast(type, T::Types::TypedHash).type, T::Types::FixedArray)
        coerced_hash = {}
        errors = []
        issues = T.let([], T::Array[ValidationIssue])

        value.each do |k, v|
          segment = k.is_a?(Integer) ? k : k.to_s
          key_result = Coercion.coerce(type: T::Utils.coerce(key_and_value_types.types.first), value: k)
          value_result = Coercion.coerce(type: T::Utils.coerce(key_and_value_types.types.last), value: v)

          if key_result.success? && value_result.success?
            coerced_hash[key_result.payload] = value_result.payload
          else
            if key_result.failure?
              errors << key_result.error
              issues.concat(key_result.error.issues.map { |issue| issue.prepend(segment) })
            end

            if value_result.failure?
              errors << value_result.error
              issues.concat(value_result.error.issues.map { |issue| issue.prepend(segment) })
            end
          end
        end

        if errors.empty?
          Success.new(coerced_hash)
        else
          Failure.new(CoercionError.new(errors.map(&:message).join(" | "), issues: issues))
        end
      end
    end
  end
end
