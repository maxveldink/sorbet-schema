# typed: strict
# frozen_string_literal: true

class ARLocation < T::Struct
  include ActsAsComparable

  const :name, String
end
