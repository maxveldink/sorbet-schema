# typed: strict
# frozen_string_literal: true

class ARPostStatus < T::Enum
  enums do
    Draft = new("draft")
    Published = new("published")
  end
end
