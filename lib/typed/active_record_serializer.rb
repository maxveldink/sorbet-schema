# typed: strict

module Typed
  class ActiveRecordSerializer < Serializer
    Input = type_member { {fixed: T.untyped} }
    # Keep the model type generic so eager loading/reflection does not require
    # ActiveRecord. The constructor loads the gem and validates the model class.
    Output = type_member { {upper: Object} }
    StructT = type_member { {upper: T::InexactStruct} }

    sig { returns(T::Class[Output]) }
    attr_reader :model_class

    sig { returns(T::Hash[String, T.untyped]) }
    attr_reader :associations_by_name

    sig do
      type_parameters(:S, :M)
        .params(
          schema: Schema[T.all(T::InexactStruct, T.type_parameter(:S))],
          model_class: T::Class[T.all(Object, T.type_parameter(:M))]
        )
        .returns(ActiveRecordSerializer[T.all(Object, T.type_parameter(:M)), T.all(T::InexactStruct, T.type_parameter(:S))])
    end
    def self.new(schema:, model_class:)
      super
    end

    sig { params(schema: Schema[StructT], model_class: T::Class[Output]).void }
    def initialize(schema:, model_class:)
      begin
        require "active_record"
      rescue LoadError
        raise ArgumentError, "activerecord gem is required for ActiveRecord serialization - add it to your Gemfile"
      end
      unless model_class <= ActiveRecord::Base
        raise ArgumentError, "model_class must inherit from ActiveRecord::Base"
      end

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
          hsh[key_for(field)] = coerce_ar_value(field:, value:)
        end
      end

      deserialize_from_creation_params(creation_params)
    end

    sig { override.params(struct: StructT).returns(Result[Output, SerializeError]) }
    def serialize(struct)
      return Failure.new(SerializeError.new("'#{struct.class}' cannot be serialized to target type of '#{schema.target}'.")) if struct.class != schema.target

      hsh = serialize_from_struct(struct:, should_serialize_values: true)
      active_record_class = T.cast(model_class, T.class_of(ActiveRecord::Base))
      column_names = active_record_class.column_names

      filtered = hsh.each_with_object(T.let({}, T::Hash[String, T.untyped])) do |(key, value), attrs|
        key_s = key.to_s
        association = associations_by_name[key_s]

        if association
          attrs[key_s] = association.klass.new(value) if column_names.include?(association.foreign_key)
        elsif column_names.include?(key_s)
          attrs[key_s] = value
        end
      end

      # Construction through the validated model class preserves its concrete type.
      Success.new(T.cast(active_record_class.new(filtered), Output))
    rescue ActiveRecord::AssociationTypeMismatch => e
      Failure.new(SerializeError.new(e.message))
    end

    private

    # Models are addressed by the Ruby prop name; `serialized_name` is a wire-format concern.
    sig { override.params(field: Field).returns(Symbol) }
    def key_for(field)
      field.name
    end

    sig { params(field: Field, value: T.untyped).returns(T.untyped) }
    def coerce_ar_value(field:, value:)
      return value unless value.is_a?(ActiveRecord::Base)

      nested_struct_class = struct_class_for(field.type)
      return value.attributes.transform_keys(&:to_sym) unless nested_struct_class

      nested_result = ActiveRecordSerializer.new(schema: T.cast(nested_struct_class.schema, Schema[T::InexactStruct]), model_class: value.class).deserialize(value)
      nested_result.success? ? nested_result.payload : value.attributes.transform_keys(&:to_sym)
    end

    sig { params(type: T::Types::Base).returns(T.nilable(StructClass)) }
    def struct_class_for(type)
      return nil unless Coercion::StructCoercer.used_for_type?(type)

      T.cast(T.cast(type, T::Types::Simple).raw_type, StructClass)
    end
  end
end
