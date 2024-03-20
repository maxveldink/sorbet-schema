# typed: true

class SimpleStringCoercer < Typed::Coercion::Coercer
  extend T::Generic

  Target = type_member { {fixed: String} }

  sig { override.params(type: T::Types::Base).returns(T::Boolean) }
  def used_for_type?(type)
    type == T::Utils.coerce(String)
  end

  sig { override.params(type: T::Types::Base, value: Typed::Value).returns(Typed::Result[Target, Typed::Coercion::CoercionError]) }
  def coerce(type:, value:)
    Typed::Success.new("always this value")
  end
end
