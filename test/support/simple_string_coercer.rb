# typed: true

class SimpleStringCoercer < Typed::Coercion::Coercer
  extend T::Generic

  Target = type_member { {fixed: String} }

  sig { override.params(type: T::Class[T.anything]).returns(T::Boolean) }
  def used_for_type?(type)
    type == String
  end

  sig { override.params(field: Typed::Field, value: Typed::Value).returns(Typed::Result[Target, Typed::Coercion::CoercionError]) }
  def coerce(field:, value:)
    Typed::Success.new("always this value")
  end
end
