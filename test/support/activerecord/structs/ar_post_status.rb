# typed: strict
# frozen_string_literal: true

# A single value is sufficient for this serialization fixture.
class ARPostStatus < T::Enum # standard:disable Sorbet/MultipleTEnumValues
  enums do
    Draft = new("draft")
  end
end
