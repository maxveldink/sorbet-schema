# typed: strict

module Typed
  class ApplyValidators
    extend T::Sig

    sig { params(schema: Schema).void }
    def initialize(schema:)
      @schema = schema
    end

    sig { params(params: Serializer::Params).returns(Result[Serializer::Params, ValidationError]) }
    def call(params)
      failing_results = schema.fields.map do |field|
        field.validate(params[field.name])
      end.select(&:failure?)

      case failing_results.length
      when 0
        Success.new(params)
      when 1
        Failure.new(T.must(failing_results.first).error)
      else
        Failure.new(MultipleValidationError.new(errors: failing_results.map(&:error)))
      end
    end

    private

    sig { returns(Schema) }
    attr_reader :schema
  end
end
