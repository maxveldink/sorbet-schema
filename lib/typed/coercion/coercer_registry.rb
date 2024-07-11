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
      end

      sig { params(coercer: T.class_of(Coercer)).void }
      def register(coercer)
        @available.prepend(coercer)
      end

      sig { void }
      def reset!
        @available = DEFAULT_COERCERS.clone
      end

      sig { params(type: T::Types::Base).returns(T.nilable(T.class_of(Coercer))) }
      def select_coercer_by(type:)
        @available.find { |coercer| coercer.new.used_for_type?(type) }
      end
    end
  end
end
