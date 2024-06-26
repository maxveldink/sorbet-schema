# typed: strict

module Typed
  module Coercion
    class StructCoercer < Coercer
      extend T::Generic

      Target = type_member { {fixed: T::Struct} }

      sig { override.params(type: T::Types::Base).returns(T::Boolean) }
      def used_for_type?(type)
        return false unless type.respond_to?(:raw_type)

        !!(T.cast(type, T::Types::Simple).raw_type < T::Struct)
      end

      sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
        return Failure.new(CoercionError.new("Field type must inherit from T::Struct for Struct coercion.")) unless used_for_type?(type)
        return Success.new(value) if type.recursively_valid?(value)

        return Failure.new(CoercionError.new("Value of type '#{value.class}' cannot be coerced to #{type} Struct.")) unless value.is_a?(Hash)

        values = {}

        type = T.cast(type, T::Types::Simple)

        type.raw_type.props.each do |name, prop|
          attribute_type = prop[:type_object]
          value = HashTransformer.new.deep_symbolize_keys(value)

          if value[name].nil?
            # if the value is nil but the type is nilable, no need to coerce
            next if attribute_type.respond_to?(:valid?) && attribute_type.valid?(value[name])

            return Typed::Failure.new(CoercionError.new("#{name} is required but nil given"))
          end

          # now that we've done the nil check, we can unwrap the nilable type to get the raw type
          simple_attribute_type = attribute_type.respond_to?(:unwrap_nilable) ? attribute_type.unwrap_nilable : attribute_type

          # if the prop is a struct, we need to recursively coerce it
          if simple_attribute_type.respond_to?(:raw_type) && simple_attribute_type.raw_type <= T::Struct
            Typed::HashSerializer
              .new(schema: simple_attribute_type.raw_type.schema)
              .deserialize(value[name])
              .and_then { |struct| Typed::Success.new(values[name] = struct) }
              .on_error { |error| return Typed::Failure.new(CoercionError.new("Nested hash for #{type} could not be coerced to #{name}, error: #{error}")) }
          else
            value = HashTransformer.new.deep_symbolize_keys(value)

            Coercion
              .coerce(type: attribute_type, value: value[name])
              .and_then { |coerced_value| Typed::Success.new(values[name] = coerced_value) }
          end
        end

        Success.new(type.raw_type.new(values))
      rescue ArgumentError, RuntimeError
        Failure.new(CoercionError.new("Given hash could not be coerced to #{type}."))
      end
    end
  end
end
