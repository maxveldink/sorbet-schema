# typed: strict

module Typed
  module Coercion
    class Coercer
      extend T::Sig
      extend T::Generic

      abstract!

      Target = type_member(:out)

      sig { abstract.params(type: Field::Type).returns(T::Boolean) }
      def used_for_type?(type)
      end

      sig { abstract.params(type: Field::Type, value: Value).returns(Result[Target, CoercionError]) }
      def coerce(type:, value:)
      end
    end
  end
end
