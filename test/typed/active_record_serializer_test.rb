# typed: true

require "test_helper"

class ActiveRecordSerializerTest < Minitest::Test
  # Deserialize Tests (AR model -> T::Struct)

  def test_deserialize_handles_simple_fields
    location_model = LocationModel.new(name: "Florida")
    serializer = Typed::ActiveRecordSerializer.new(schema: ARLocation.schema, model_class: LocationModel)

    result = serializer.deserialize(location_model)

    assert_success(result)
    assert_payload(ARLocation.new(name: "Florida"), result)
  end

  def test_deserialize_handles_enum_fields
    post_model = PostModel.new(title: "Testing 123", status: "draft")
    serializer = Typed::ActiveRecordSerializer.new(schema: ARPost.schema, model_class: PostModel)

    result = serializer.deserialize(post_model)

    assert_success(result)
    assert_payload(ARPost.new(title: "Testing 123", status: ARPostStatus::Draft), result)
  end

  def test_deserialize_handles_nested_struct_fields
    location_model = LocationModel.new(name: "Florida")
    user_model = UserModel.new(name: "Max", age: 28, location: location_model)
    serializer = Typed::ActiveRecordSerializer.new(schema: ARUser.schema, model_class: UserModel)

    result = serializer.deserialize(user_model)

    assert_success(result)
    assert_payload(ARUser.new(name: "Max", age: 28, location: ARLocation.new(name: "Florida")), result)
  end

  def test_deserialize_handles_arbitrary_depth_nested_struct_fields
    country_model = CountryModel.new(name: "US")
    location_model = LocationModel.new(name: "Florida", country: country_model)
    user_model = UserModel.new(name: "Max", age: 28, location: location_model)
    serializer = Typed::ActiveRecordSerializer.new(schema: ARUser.schema, model_class: UserModel)

    result = serializer.deserialize(user_model)

    assert_success(result)
    assert_payload(
      ARUser.new(name: "Max", age: 28, location: ARLocation.new(name: "Florida", country: ARCountry.new(name: "US"))),
      result
    )
  end

  def test_deserialize_when_model_has_extra_columns_only_maps_struct_fields
    pet_model = ComplexPetModel.new(name: "Sadie", breed: "Brittany", age: 2, pedigree: true)
    serializer = Typed::ActiveRecordSerializer.new(schema: ARPet.schema, model_class: ComplexPetModel)

    result = serializer.deserialize(pet_model)

    assert_success(result)
    assert_payload(ARPet.new(name: "Sadie", breed: "Brittany"), result)
  end

  def test_deserialize_fails_for_non_activerecord_object
    serializer = Typed::ActiveRecordSerializer.new(schema: ARLocation.schema, model_class: LocationModel)

    result = serializer.deserialize("not an AR model")

    assert_failure(result)
    assert_error(Typed::DeserializeError.new("Cannot deserialize a non-ActiveRecord object."), result)
  end

  def test_deserialize_fails_for_wrong_model_class
    location_model = LocationModel.new(name: "Florida")
    serializer = Typed::ActiveRecordSerializer.new(schema: ARPost.schema, model_class: PostModel)

    result = serializer.deserialize(location_model)

    assert_failure(result)
    assert_error(Typed::DeserializeError.new("'LocationModel' is not an instance of 'PostModel'."), result)
  end

  # Serialize Tests (T::Struct -> AR model)

  def test_serialize_handles_simple_fields
    location_struct = ARLocation.new(name: "Florida")
    serializer = Typed::ActiveRecordSerializer.new(schema: ARLocation.schema, model_class: LocationModel)

    result = serializer.serialize(location_struct)

    assert_success(result)
    model = result.payload
    assert_kind_of LocationModel, model
    model = T.cast(model, T.untyped)
    assert_equal "Florida", model.name
  end

  def test_serialize_handles_enum_fields
    post_struct = ARPost.new(title: "Testing 123", status: ARPostStatus::Draft)
    serializer = Typed::ActiveRecordSerializer.new(schema: ARPost.schema, model_class: PostModel)

    result = serializer.serialize(post_struct)

    assert_success(result)
    model = result.payload
    assert_kind_of PostModel, model
    model = T.cast(model, T.untyped)
    assert_equal "Testing 123", model.title
    assert_equal "draft", model.status
  end

  def test_serialize_handles_nested_struct_via_association
    user_struct = ARUser.new(name: "Max", age: 28, location: ARLocation.new(name: "Florida"))
    serializer = Typed::ActiveRecordSerializer.new(schema: ARUser.schema, model_class: UserModel)

    result = serializer.serialize(user_struct)

    assert_success(result)
    model = result.payload
    assert_kind_of UserModel, model
    model = T.cast(model, T.untyped)
    assert_equal "Max", model.name
    assert_equal 28, model.age
    assert_kind_of LocationModel, model.location
    assert_equal "Florida", model.location.name
  end

  def test_serialize_filters_to_model_columns
    pet_struct = ARPet.new(name: "Sadie", breed: "Brittany")
    serializer = Typed::ActiveRecordSerializer.new(schema: ARPet.schema, model_class: SimplePetModel)

    result = serializer.serialize(pet_struct)

    assert_success(result)
    model = result.payload
    assert_kind_of SimplePetModel, model
    model = T.cast(model, T.untyped)
    assert_equal "Brittany", model.breed
    refute model.attributes.key?("name")
  end

  def test_serialize_fails_for_renamed_foreign_key_association
    home_struct = ARUserHome.new(name: "Max", home: ARLocation.new(name: "Florida"))
    serializer = Typed::ActiveRecordSerializer.new(schema: ARUserHome.schema, model_class: UserWithHomeModel)

    result = serializer.serialize(home_struct)

    assert_success(result)
    model = result.payload
    assert_kind_of UserWithHomeModel, model
    model = T.cast(model, T.untyped)
    assert_kind_of LocationModel, model.home
    assert_equal "Florida", model.home.name
  end

  def test_serialize_does_not_raise_for_two_level_nested_struct
    country_struct = ARCountry.new(name: "US")
    location_struct = ARLocation.new(name: "Florida", country: country_struct)
    user_struct = ARUser.new(name: "Max", age: 28, location: location_struct)
    serializer = Typed::ActiveRecordSerializer.new(schema: ARUser.schema, model_class: UserModel)

    result = serializer.serialize(user_struct)

    assert_failure(result)
    assert_kind_of Typed::SerializeError, result.error
  end

  def test_serialize_fails_for_wrong_struct_type
    location_struct = ARLocation.new(name: "Florida")
    serializer = Typed::ActiveRecordSerializer.new(schema: ARPost.schema, model_class: PostModel)

    result = serializer.serialize(location_struct)

    assert_failure(result)
    assert_error(Typed::SerializeError.new("'ARLocation' cannot be serialized to target type of 'ARPost'."), result)
  end

  # T::Struct convenience method tests

  def test_deserialize_from_activerecord
    location_model = LocationModel.new(name: "Florida")

    result = ARLocation.deserialize_from(:activerecord, location_model, options: {model_class: LocationModel})

    assert_success(result)
    assert_payload(ARLocation.new(name: "Florida"), result)
  end

  def test_serialize_to_activerecord
    location_struct = ARLocation.new(name: "Florida")

    result = location_struct.serialize_to(:activerecord, options: {model_class: LocationModel})

    assert_success(result)
    model = result.payload
    assert_kind_of LocationModel, model
    assert_equal "Florida", model.name
  end

  # Persisted record tests (eager loading)

  def test_deserialize_persisted_records_supports_eager_loading_to_avoid_n_plus_one
    ActiveRecord::Base.transaction do
      location = LocationModel.create!(name: "Florida")
      3.times { |i| UserModel.create!(name: "User #{i}", age: 20 + i, location:) }

      serializer = Typed::ActiveRecordSerializer.new(schema: ARUser.schema, model_class: UserModel)

      without_includes_query_count = count_queries { UserModel.all.each { |user| serializer.deserialize(user) } }
      with_includes_query_count = count_queries { UserModel.includes(:location).load.each { |user| serializer.deserialize(user) } }

      assert_equal 4, without_includes_query_count # 1 for users + 1 per-user location lookup (N+1)
      assert_equal 2, with_includes_query_count # 1 for users + 1 batched location lookup

      raise ActiveRecord::Rollback
    end
  end

  private

  def count_queries(&)
    count = 0
    callback = ->(*, payload) { count += 1 unless payload[:name] == "SCHEMA" }

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record", &)

    count
  end
end
