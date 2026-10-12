# typed: true

class Currency < T::Enum
  enums do
    USD = new("USD")
    EUR = new("EUR")
  end
end
