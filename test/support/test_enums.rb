# typed: true

class TestEnums < T::Enum
  enums do
    EnumOne = new("1")
    EnumTwo = new("2")
    EnumThree = new("3")
  end
end
