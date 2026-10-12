# typed: strict

module Typed
  class ValidationIssue < T::ImmutableStruct
    extend T::Sig

    PathSegment = T.type_alias { T.any(String, Integer) }
    Path = T.type_alias { T::Array[PathSegment] }

    const :path, Path, factory: -> { [] }
    const :code, Symbol
    const :message, String

    sig { params(segment: PathSegment).returns(ValidationIssue) }
    def prepend(segment)
      ValidationIssue.new(path: [segment, *path], code: code, message: message)
    end

    sig { returns({path: Path, code: Symbol, message: String}) }
    def to_h
      {path: path, code: code, message: message}
    end
  end
end
