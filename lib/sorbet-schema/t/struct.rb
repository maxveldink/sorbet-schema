# typed: strict

module T
  class Struct
    extend T::Sig

    sig { overridable.returns(Typed::Schema) }
    def self.schema
      Typed::Schema.from_struct(self)
    end
  end
end
