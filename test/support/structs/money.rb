# typed: false

require_relative "../enums/currency"

class Money < T::Struct
  include ActsAsComparable

  const :cents, Integer
  const :currency, Currency, default: Currency::USD
end
