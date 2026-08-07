# Sorbet Schema

Extendable serialization and deserialization to various formats for Sorbet `T::Struct`s.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add sorbet-schema

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install sorbet-schema

## Usage

Sorbet Schema is designed to be compatible with Sorbet's `T::Struct` class, and seeks to update many of the common pitfalls developers encountering when deserializing to and serializing from a `T::Struct`.

### Getting Started

While you can directly define a `Typed::Schema` to be used for your serialization needs, you'll typically use the provided helper class method to generate a `Schema` from an existing `T::Struct`.

```ruby
class Person < T::Struct
  const :name, String
  const :age, Integer
end

schema = Person.schema # => <Typed::Schema
#                              fields=[....]
#                              target=Person>
```

Once you have a schema, you can use the built-in serializers (or a [custom one](#implementing-custom-serializers) that inherits from the [Typed::Serializer](https://github.com/maxveldink/sorbet-schema/blob/main/lib/typed/serializer.rb) abstract base class) to create new instances of the struct or convert an instance of the struct to the target format.

```ruby
json_serializer = Typed::JSONSerializer.new(schema: Person.schema)

# Deserialize from target format
result = json_serializer.deserialize('{"name":"Max","age":29}')
max = result.payload # == Person.new(name: "Max", age: 29)

result = json_serializer.serialize(max)
result.payload # == '{"name":"Max","age":29}'
```

Alternatively, you can use the built-in helper methods added to `T::Struct`s to quickly use the built-in serializers.

```ruby
result = Person.deserialize_from(:json, '{"name":"Max","age":29}')
max = result.payload # == Person.new(name: "Max", age: 29)

result = max.serialize_to(:json)
result.payload # == '{"name":"Max","age":29}'
```

`:hash`, `:json`, `:csv`, `:yml`, and `:msgpack` are all supported as the first argument to `deserialize_from`/`serialize_to` (and the equivalent `from_hash`/`from_json`/`from_csv`/`from_yml`/`from_msgpack` methods on `Typed::Schema`), corresponding to the built-in serializers below.

Notice that both `deserialize` and `serialize` return `Typed::Result`s (from the [sorbet-result gem](https://github.com/maxveldink/sorbet-result)) that need to be checked for success or failure before being used. Check out that gem's README for more information on how to interact with `Result`s.

One benefit of using `Result`s is we can add much more details information about why a format is unsuccessfully deserialized or serialized, to provide call sites with more information for error handling, messaging and formatting.

```ruby
# Unparsable JSON
result = json_serializer.deserialize('{"name""Max","age":29}')
result.error # == Typed::ParseError: json could not be parsed. Check for typos.

# Missing required field
result = json_serializer.deserialize('{"age": 29}')
result.error # == Typed::Validations::RequiredFieldError: name is required.

result = json_serializer.deserialize('{"age":"29-0"}')
result.error # == Typed::Validations::MultipleValidationError: Multiple validation errors found: name is required. | '29-0' cannot be coerced into Integer.
```

Finally, there are built-in coercers that do their best effort to convert common types from the source format to the required schema type.

```ruby
# Deserialize from target format, with integer coercion
result = json_serializer.deserialize('{"name":"Max","age":"29"}')
max = result.payload # == Person.new(name: "Max", age: 29)
```

### Rails Example

Here's an extended example of how Sorbet Schema can be combined with a normal Rails request to easily convert between formats.

```ruby
def verify
  Typed::HashSerializer
    .new(schema: Address.schema) # Generate schema from the `Address` Struct
    .deserialize(address_params.to_h) # Use Rails' strong parameters to deserialize into the struct
    .and_then { |address| VerifyAddress.new.call(address: T.cast(address, Address)) } # Use sorbet-result's chaining
    .and_then do |address|
        return render json: Typed::JSONSerializer.new(schema: Address.schema).serialize(address).payload # return a JSON response from the Address struct instance
    end
    .on_error do |failure| # Use sorbet-result's error handling
      case failure
      when AddressNotFoundError
        head :not_found
      when GeoNotSupportedError
        head :not_implemented
      else
        render json: failure, status: :bad_request # use `Typed::Failure`s built-in `to_json` behavior
      end
    end
end
```

### Available Serializers

These are the currently available serializers. For more information about implementing a custom one (or contributing one back!), see [Custom Coercers](#custom-coercers).

`HashSerializer`, `JSONSerializer`, and `YMLSerializer` work out of the box with no extra dependencies. `CSVSerializer` and `MessagePackSerializer` require you to add the `csv` and `msgpack` gems, respectively, to your own Gemfile - they are not pulled in as runtime dependencies of `sorbet-schema` itself. Referencing `:csv`/`:msgpack` via `serializer`/`deserialize_from`/`serialize_to` without the gem installed raises a clear `ArgumentError` telling you which gem to add.

#### JSONSerializer

See [Getting Started](#getting-started) for more information on how to use the JSONSerializer.

#### HashSerializer

While not strictly serialization, converting `T::Struct`s to and from Ruby `Hash`es has traditionally had many pitfalls ([well-documented](https://sorbet.org/docs/tstruct#legacy-code-and-historical-context) in the Sorbet docs). The `Typed::HashSerializer` aims to address several common issues, while providing the same `Result` handling for invalid or missing data and coercion behavior.

To use it, simply instantiate and use it like the `JSONSerializer`:

```ruby
hash_serializer = Typed::HashSerializer.new(schema: Person.schema)

# Deserialize from target format
result = hash_serializer.deserialize({"name" => "Max", age: 29})
max = result.payload # == Person.new(name: "Max", age: 29)
```

By default, the `HashSerializer` will _not_ serialize values when converting to a Hash. For instance, if a field is an `T::Enum` type, when it is serialized to a `Hash` the value will be the `Enum` and not the `String` representation. The `should_serialize_values` option can be passed during initialization to serialize the values when converting to the `Hash`.

#### CSVSerializer

Accepts and returns a CSV string representing a single record, with a header row followed by one data row:

```ruby
csv_serializer = Typed::CSVSerializer.new(schema: Person.schema)

# Deserialize from target format
result = csv_serializer.deserialize("name,age\nMax,29\n")
max = result.payload # == Person.new(name: "Max", age: 29)

# Serialize to target format
result = csv_serializer.serialize(max)
result.payload # == "name,age\nMax,29\n"
```

CSV is a flat, row-based format, so nested `T::Struct`s, `Hash`es, and `Array`s cannot be represented as their own columns. Rather than writing a lossy representation into a cell that can never be parsed back correctly, `CSVSerializer#serialize` returns a `Typed::SerializeError` naming the offending field(s) when a struct has one. Prefer this serializer for schemas with scalar fields only, or use an `inline_serializer` (see [Inline Serializers](#inline-serializers)) to flatten a nested field into a scalar before serializing it to CSV.

#### YMLSerializer

Works just like the `JSONSerializer`, but with YAML strings:

```ruby
yml_serializer = Typed::YMLSerializer.new(schema: Person.schema)

# Deserialize from target format
result = yml_serializer.deserialize("---\nname: Max\nage: 29\n")
max = result.payload # == Person.new(name: "Max", age: 29)

# Serialize to target format
result = yml_serializer.serialize(max)
result.payload # == "---\nname: Max\nage: 29\n"
```

#### MessagePackSerializer

Works just like the `JSONSerializer`, but with [MessagePack](https://msgpack.org/) binary-encoded strings, using the [`msgpack`](https://github.com/msgpack/msgpack-ruby) gem:

```ruby
message_pack_serializer = Typed::MessagePackSerializer.new(schema: Person.schema)

# Deserialize from target format
result = message_pack_serializer.deserialize(MessagePack.pack({"name" => "Max", "age" => 29}))
max = result.payload # == Person.new(name: "Max", age: 29)

# Serialize to target format
result = message_pack_serializer.serialize(max)
result.payload # == MessagePack.pack({"name" => "Max", "age" => 29})
```

Unlike `CSVSerializer`, MessagePack natively supports nested maps and arrays, so nested `T::Struct`s, `Hash`es, and `Array`s round-trip without any `inline_serializer` needed.

#### ActiveRecordSerializer

Requires the `activerecord` gem to be available. This is only checked when going through `.serializer(:activerecord)`, which raises an `ArgumentError` if the gem isn't loaded; calling `Typed::ActiveRecordSerializer.new` directly without ActiveRecord loaded instead raises a `NameError`, since the class itself references the `ActiveRecord` constant. The `Typed::ActiveRecordSerializer` converts between `ActiveRecord::Base` model instances and `T::Struct`s, matching fields by attribute name and mapping associated records through the model's declared associations. It requires a `model_class` option, in addition to `schema`, so it knows which `ActiveRecord::Base` subclass to deserialize from and serialize to:

```ruby
ar_serializer = Typed::ActiveRecordSerializer.new(schema: Person.schema, model_class: PersonModel)

# Deserialize from target format
result = ar_serializer.deserialize(PersonModel.new(name: "Max", age: 29))
max = result.payload # == Person.new(name: "Max", age: 29)

result = ar_serializer.serialize(max)
result.payload # == PersonModel instance with name: "Max", age: 29
```

When serializing, only fields that map to a column (or to an association's declared foreign key) on `model_class` are assigned; the rest are ignored.

Nested `belongs_to` associations are deserialized recursively to arbitrary depth, so a `T::Struct` field whose type is itself a `T::Struct` backed by a `belongs_to` association will have its own nested associations resolved too.

Deserializing reads through the model's association readers, so it is subject to the same N+1 query behavior as any other Rails association access. Preloading with `includes` works transparently and is the recommended way to avoid a query per record per association when deserializing a collection:

```ruby
# 1 query for people + 1 query for locations, instead of 1 + N
PersonModel.includes(:location).find_each do |person_model|
  ar_serializer.deserialize(person_model)
end
```

### Customization

From the get-go, Sorbet Schema is designed to be extensible to model more complex data validation requirements and many serialization formats. We try out best to include built-in, battle-tested coercers and serializers from real world use cases and would love to see/upstream any customizations that the community have found useful!

#### Custom Coercers

At their simplest forms, coercers are any class that inherit from the [Typed::Coercion::Coercer](https://github.com/maxveldink/sorbet-schema/blob/main/lib/typed/coercion/coercer.rb) abstract base class. The list of default coercers that are applied can be found in the [CoercerRegistry](https://github.com/maxveldink/sorbet-schema/blob/main/lib/typed/coercion/coercer_registry.rb). Let's look at the [DateCoercer's implementation](https://github.com/maxveldink/sorbet-schema/blob/main/lib/typed/coercion/date_coercer.rb):

```ruby
require "date"

class DateCoercer < Coercer
  extend T::Generic

  Target = type_member { {fixed: Date} }

  sig { override.params(type: T::Types::Base).returns(T::Boolean) }
  def used_for_type?(type)
    T::Utils.coerce(type) == T::Utils.coerce(Date)
  end

  sig { override.params(type: T::Types::Base, value: Value).returns(Result[Target, CoercionError]) }
  def coerce(type:, value:)
    return Failure.new(CoercionError.new("Type must be a Date.")) unless used_for_type?(type)

    return Success.new(value) if value.is_a?(Date)

    Success.new(Date.parse(value))
  rescue Date::Error, TypeError
    Failure.new(CoercionError.new("'#{value}' cannot be coerced into Date."))
  end
end
```

Notice that this utilizes sorbet generic, so the target type must be defined using `type_member`. For dates, this is the built-in std lib type `Date`.

From there, implement the `used_for_type?` method which receives a type and returns `true` if the coercer can be used to coerce to that type or `false` if it should not be used. Notice that we use the `T::Types` module directly from Sorbet, which allows us to model the built-in Sorbet types, such as `T::Boolean` and `T::Array`. Typically, `T::Utils.coerce(TargetType)` is used to match the target type. For dates, this is a very simple type check for a `Date`.

Finally, implement the `coerce` method. If a coercion is successful, return a `Success.new(coerced_value)`. If not, return a Failure with a coercion error `Failure.new(CoercionError.new("I can't coerce to the type"))`. Take care to handle any exceptions that could arise from the attempted coercion. For dates, first it checks and make sure the type given matches the target type. This is a common check and is largely an edge case check for completeness. Next, if the value is already a Date we simply return a `Success` with it. Finally, we use the built-in `Date.parse` method to actually attempt a coercion. Since this can throw a `Date::Error` and a `TypeError`, rescue from those with a `Failure`.

Once a custom coercer is defined, the last step is to register it with Sorbet Schema during initialization. Typically, this is after `sorbet-schema` has been required or during the bootstrapping step of a framework, such as Rails' initializers. Call `register_coercer` like so:

```ruby
Typed::Coercion.register_coercer(MyCoercer) # make sure `MyCoercer` is loaded by this point
```

**Note** Custom coercers are prepended to the list of available coercers so that they are checked during deserialization before the built-in coercers. This allows consuming projects to override default behavior by creating a coercer that re-implements the `coerce` method for that type.

#### Inline Serializers

Sometimes, there is custom behavior that needs to be added to how a field is serialized (represented as a `String`), such as when you need to use a different `strftime` format for `Date`s and `Time`s. This can be accomplished with an `InlineSerializer` (defined in [Typed::Field](https://github.com/maxveldink/sorbet-schema/blob/main/lib/typed/field.rb)), which is a `Proc` that takes the value and returns a different representation. At present, these are both very loose `T.untyped` types to allow for flexibility. Typically, a `String` is returned.

The serializer can be used when creating a `Schema` and defining its `fields`, or with the `add_serializer` helper on `Schema`s.

```ruby
my_date_serializer = ->(date) { date.strftime("%Y/%m") }

# use directly on a Schema - `Typed::Schema` is generic over its target struct,
# so prefer `from_struct`, which infers the type argument, over `Schema.new`
Typed::Schema.from_struct(SchemaWithDateField).add_serializer(:date, my_date_serializer)

# or, if you need custom `fields` up front, specify the type argument explicitly
Typed::Schema[SchemaWithDateField].new(
  target: SchemaWithDateField,
  fields: [
    Typed::Field.new(name: :date, type: Date, serializer: my_date_serializer)
  ]
)

# use `add_serializer` helper
SchemaWithDateField.schema.add_serializer(:date, my_date_serializer)
```

#### Implementing Custom Serializers

While Sorbet Schema ships with popular serializers, you can define your own by inheriting from [Typed::Serializer](https://github.com/maxveldink/sorbet-schema/blob/main/lib/typed/serializer.rb). Let's look at the `JSONSerializer`:

```ruby
require "json"

class JSONSerializer < Serializer
  Input = type_member { {fixed: String} }
  Output = type_member { {fixed: String} }
  StructT = type_member { {upper: T::Struct} }

  sig { override.params(source: Input).returns(Result[StructT, DeserializeError]) }
  def deserialize(source)
    parsed_json = JSON.parse(source)

    creation_params = schema.fields.each_with_object(T.let({}, Params)) do |field, hsh|
      hsh[field.name] = parsed_json[field.name.to_s]
    end

    deserialize_from_creation_params(creation_params)
  rescue JSON::ParserError
    Failure.new(ParseError.new(format: :json))
  end

  sig { override.params(struct: StructT).returns(Result[Output, SerializeError]) }
  def serialize(struct)
    return Failure.new(SerializeError.new("'#{struct.class}' cannot be serialized to target type of '#{schema.target}'.")) if struct.class != schema.target

    Success.new(JSON.generate(serialize_from_struct(struct: struct, should_serialize_values: true)))
  end
end
```

Since `Serializer` is a generic class, we need to define our `Input`, `Output`, and `StructT` types. For JSON, deserialization and serialization both use JSON strings, so `Input`/`Output` are both `String`. `StructT` is the struct type the serializer round-trips to/from - it must always be re-declared as `type_member { {upper: T::Struct} }` in the subclass (Sorbet requires each generic type member to be re-declared down the inheritance chain), and using it in `deserialize`/`serialize` (instead of `T::Struct`) is what lets every deserialize path narrow to the concrete struct type instead of widening to `T::Struct`.

Next, the `deserialize` and `serialize` methods must be implemented. Notice that both of these return `Result`s.

For deserialization, the JSON is parsed (and a parse error is handled). Then we build up a creation params hash from the parsed json to pass to the `deserialize_from_creation_params` helper, defined on `Serializer`.

For serialization, the passed struct is checked to make sure it matches the `Schema`. Then it uses the `serialize_from_struct` helper and passes the resulting `Hash` to generate JSON.

## Inspirations

This project is heavily inspired by [serde](https://serde.rs/) from the Rust community and the [dry-rb](https://dry-rb.org/) family of gems.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run Standard and the tests. `bin/console` for an interactive prompt that aids with experimentation.

To install this gem onto a local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/maxveldink/sorbet-schema. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/maxveldink/sorbet-schema/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in this project's codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/maxveldink/sorbet-schema/blob/master/CODE_OF_CONDUCT.md).

## Sponsorships

I love creating in the open. If you find this or any other [maxveld.ink](https://maxveld.ink) content useful, please consider sponsoring me on [GitHub](https://github.com/sponsors/maxveldink).
