# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.
- Ruby 3.4+ unbundles former stdlib gems (e.g. `csv`) from the default load path, so `require "csv"` is not free — it needs the gem actually installed.
- Format-specific serializers keep their backing gems optional: load the gem in `initialize`, raise a clear `ArgumentError` on `LoadError`, and keep class-body signatures safe to reflect without the gem installed. See `lib/typed/csv_serializer.rb` and `lib/typed/active_record_serializer.rb`; the latter uses a generic model output instead of referencing `ActiveRecord::Base` in signatures. Verify eager loading changes with `bundle exec tapioca gem` in a consumer bundle without `activerecord`, and keep the factory's missing-gem behavior consistent.
- Every `Typed::Serializer` subclass (all six format serializers) and `Typed::Schema` are generic over the struct type via a `StructT = type_member { {upper: T::InexactStruct} }` re-declared in each subclass — `T::InexactStruct` is Sorbet's common superclass for `T::Struct` and `T::ImmutableStruct`; Sorbet cannot propagate their union as a type-member bound. This lets every deserialize path (`deserialize_from`, `.serializer(:x).deserialize`, `.schema.from_x`, direct serializer construction) return the concrete struct type with no `T.cast`. `Typed::Schema#target` is `T.all(T::Class[StructT], StructClass)`, not the bare `T::Class[StructT]`: Sorbet runtime erases `T::Class[X]` to `T::Class[T.untyped]`, while the `StructClass` intersection restores the runtime restriction to `T::Struct`/`T::ImmutableStruct` descendants. See `lib/typed/serializer.rb`, `lib/typed/schema.rb`, and `lib/typed/hash_serializer.rb`'s `self.new` override (the one class that needs it, for direct-construction type inference) for the exact shape when adding a new serializer.
- After adding a new *required* runtime gem dependency (not this optional-serializer case), run `bundle exec tapioca gem` (add the gem to `sorbet/tapioca/require.rb` first if it isn't required anywhere else) so `bundle exec rake` (which runs `srb tc`) has an RBI to check against.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
