# typed: true

require "date"

class CoercerRegistryTest < Minitest::Test
  def teardown
    Typed::Coercion::CoercerRegistry.instance.reset!
  end

  def test_register_prepends_coercer_so_it_overrides_built_in_ones
    Typed::Coercion::CoercerRegistry.instance.register(SimpleStringCoercer)

    assert_equal(SimpleStringCoercer, Typed::Coercion::CoercerRegistry.instance.select_coercer_by(type: T::Utils.coerce(String)))
  end

  def test_when_type_doesnt_match_coercer_returns_nil
    assert_nil(Typed::Coercion::CoercerRegistry.instance.select_coercer_by(type: T::Utils.coerce(BigDecimal)))
  end
end
