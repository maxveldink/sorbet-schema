# typed: strict

module Typed
  class ActiveRecordSerializer < Serializer
    Input = type_member { {fixed: T.untyped} }
    Output = type_member { {fixed: T.untyped} }

    sig { returns(T.class_of(ActiveRecord::Base)) }
    attr_reader :model_class

    sig { params(schema: Schema, model_class: T.class_of(ActiveRecord::Base)).void }
    def initialize(schema:, model_class:)
      @model_class = model_class

      super(schema: schema)
    end

    sig { override.params(source: Input).returns(Result[T::Struct, DeserializeError]) }
    def deserialize(source)
      return Failure.new(DeserializeError.new("Cannot deserialize a non-ActiveRecord object.")) unless source.is_a?(ActiveRecord::Base)

      return Failure.new(DeserializeError.new("'#{source.class}' is not an instance of '#{model_class}'.")) unless source.is_a?(T.unsafe(model_class))

      creation_params = schema.fields.each_with_object(T.let({}, Params)) do |field, hsh|
        if source.respond_to?(field.name)
          value = source.send(field.name)
          hsh[field.name] = coerce_ar_value(value)
        end
      end

      deserialize_from_creation_params(creation_params)
    end

    sig { override.params(struct: T::Struct).returns(Result[Output, SerializeError]) }
    def serialize(struct)
      return Failure.new(SerializeError.new("'#{struct.class}' cannot be serialized to target type of '#{schema.target}'.")) if struct.class != schema.target

      hsh = serialize_from_struct(struct:, should_serialize_values: true)
      column_names = model_class.column_names

      filtered = hsh.each_with_object(T.let({}, T::Hash[String, T.untyped])) do |(key, value), attrs|
        key_s = key.to_s

        if column_names.include?(key_s)
          attrs[key_s] = value
        elsif column_names.include?("#{key_s}_id")
          association = model_class.reflect_on_all_associations.find { |a| a.name.to_s == key_s }

          if association
            attrs[key_s] = association.klass.new(value)
          end
        end
      end

      Success.new(T.unsafe(model_class.new(filtered)))
    end

    private

    sig { params(value: T.untyped).returns(T.untyped) }
    def coerce_ar_value(value)
      if value.is_a?(ActiveRecord::Base)
        value.attributes.transform_keys(&:to_sym)
      else
        value
      end
    end
  end
end
