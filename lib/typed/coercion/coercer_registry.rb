# typed: strict

require "singleton"

module Typed
  module Coercion
    class CoercerRegistry
      extend T::Sig

      include Singleton

      sig { void }
      def initialize
        @available = T.let([StringCoercer, IntegerCoercer, FloatCoercer, StructCoercer], T::Array[T.class_of(Coercer)])
      end

      sig { params(coercer: T.class_of(Coercer)).void }
      def register(coercer)
        @available.prepend(coercer)
      end

      sig { params(type: T::Class[T.anything]).returns(T.nilable(T.class_of(Coercer))) }
      def select_coercer_by(type:)
        @available.find { |coercer| coercer.new.used_for_type?(type) }
      end
    end
  end
end
