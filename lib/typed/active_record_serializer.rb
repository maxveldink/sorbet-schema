# typed: strict

module Typed
  class ActiveRecordSerializer < Serializer
    Input = type_member { {fixed: T.untyped} }
    Output = type_member { {fixed: ActiveRecord::Base} }
    StructT = type_member { {upper: T::Struct} }

    sig { returns(T.class_of(ActiveRecord::Base)) }
    attr_reader :model_class

    sig { returns(T::Hash[String, T.untyped]) }
    attr_reader :associations_by_name

    sig { params(schema: Schema[StructT], model_class: T.class_of(ActiveRecord::Base)).void }
    def initialize(schema:, model_class:)
      @model_class = model_class
      @associations_by_name = T.let(
        model_class.reflect_on_all_associations.each_with_object({}) { |association, hsh| hsh[association.name.to_s] = association },
        T::Hash[String, T.untyped]
      )

      super(schema: schema)
    end

    sig { override.params(source: Input).returns(Result[StructT, DeserializeError]) }
    def deserialize(source)
      return Failure.new(DeserializeError.new("Cannot deserialize a non-ActiveRecord object.")) unless source.is_a?(ActiveRecord::Base)

      return Failure.new(DeserializeError.new("'#{source.class}' is not an instance of '#{model_class}'.")) unless source.class <= model_class

      creation_params = schema.fields.each_with_object(T.let({}, Params)) do |field, hsh|
        if source.respond_to?(field.name)
          value = source.send(field.name)
          hsh[field.name] = coerce_ar_value(field:, value:)
        end
      end

      deserialize_from_creation_params(creation_params)
    end

    sig { override.params(struct: StructT).returns(Result[Output, SerializeError]) }
    def serialize(struct)
      return Failure.new(SerializeError.new("'#{struct.class}' cannot be serialized to target type of '#{schema.target}'.")) if struct.class != schema.target

      hsh = serialize_from_struct(struct:, should_serialize_values: true)
      column_names = model_class.column_names

      filtered = hsh.each_with_object(T.let({}, T::Hash[String, T.untyped])) do |(key, value), attrs|
        key_s = key.to_s
        association = associations_by_name[key_s]

        if association
          attrs[key_s] = association.klass.new(value) if column_names.include?(association.foreign_key)
        elsif column_names.include?(key_s)
          attrs[key_s] = value
        end
      end

      Success.new(model_class.new(filtered))
    rescue ActiveRecord::AssociationTypeMismatch => e
      Failure.new(SerializeError.new(e.message))
    end

    private

    sig { params(field: Field, value: T.untyped).returns(T.untyped) }
    def coerce_ar_value(field:, value:)
      return value unless value.is_a?(ActiveRecord::Base)

      nested_struct_class = struct_class_for(field.type)
      return value.attributes.transform_keys(&:to_sym) unless nested_struct_class

      nested_result = ActiveRecordSerializer.new(schema: nested_struct_class.schema, model_class: value.class).deserialize(value)
      nested_result.success? ? nested_result.payload : value.attributes.transform_keys(&:to_sym)
    end

    sig { params(type: T::Types::Base).returns(T.nilable(T.class_of(T::Struct))) }
    def struct_class_for(type)
      return nil unless type.respond_to?(:raw_type)

      raw_type = T.cast(type, T::Types::Simple).raw_type
      (raw_type < T::Struct) ? raw_type : nil
    end
  end
end
