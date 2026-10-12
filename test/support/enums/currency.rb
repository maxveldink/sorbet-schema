# typed: true

# A single value is sufficient for this serialization fixture.
class Currency < T::Enum # standard:disable Sorbet/MultipleTEnumValues
  enums do
    USD = new("USD")
  end
end
