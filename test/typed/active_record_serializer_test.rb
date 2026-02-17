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
    assert_equal "Florida", model.name
  end

  def test_serialize_handles_enum_fields
    post_struct = ARPost.new(title: "Testing 123", status: ARPostStatus::Draft)
    serializer = Typed::ActiveRecordSerializer.new(schema: ARPost.schema, model_class: PostModel)

    result = serializer.serialize(post_struct)

    assert_success(result)
    model = result.payload
    assert_kind_of PostModel, model
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
    assert_equal "Brittany", model.breed
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
end
