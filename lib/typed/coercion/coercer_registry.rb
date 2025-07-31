# typed: strict

require "singleton"

module Typed
  module Coercion
    class CoercerRegistry
      extend T::Sig

      include Singleton

      Registry = T.type_alias { T::Array[T.class_of(Coercer)] }

      DEFAULT_COERCERS = T.let(
        [
          StringCoercer,
          SymbolCoercer,
          BooleanCoercer,
          IntegerCoercer,
          FloatCoercer,
          DateCoercer,
          DateTimeCoercer,
          EnumCoercer,
          StructCoercer,
          TypedArrayCoercer,
          TypedHashCoercer
        ],
        Registry
      )

      sig { void }
      def initialize
        @available = T.let(DEFAULT_COERCERS.clone, Registry)
        @coercer_cache = T.let({}, T::Hash[String, Coercer])
      end

      sig { params(coercer: T.class_of(Coercer)).void }
      def register(coercer)
        @available.prepend(coercer)
      end

      sig { void }
      def reset!
        @available = DEFAULT_COERCERS.clone
        @coercer_cache.clear
      end

      sig { params(type: T::Types::Base).returns(T.nilable(Coercer)) }
      def select_coercer_by(type:)
        cache_key = type.to_s
        if @coercer_cache.key?(cache_key)
          return @coercer_cache[cache_key]
        end

        klass = @available.find { |coercer| coercer.new.used_for_type?(type) }
        instance = klass&.new
        @coercer_cache[cache_key] = instance if instance
        instance
      end
    end
  end
end
