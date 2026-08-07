# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.
- Ruby 3.4+ unbundles former stdlib gems (e.g. `csv`) from the default load path, so `require "csv"` is not free — it needs the gem actually installed.
- Format-specific serializers (`CSVSerializer`, `MessagePackSerializer`, `ActiveRecordSerializer`) treat their backing gem as optional: no top-level `require`, gem is `add_development_dependency` only (not `add_runtime_dependency`), the `require`/gem-presence check happens lazily in `initialize` with a clear `ArgumentError` on failure, and `T::Struct.serializer`'s factory (`lib/sorbet-schema/t/struct.rb`) mirrors that same guard via `defined?(...)`. Follow this pattern for any new serializer/coercer with a non-stdlib dependency; see `lib/typed/csv_serializer.rb` for the exact shape.
- After adding a new *required* runtime gem dependency (not this optional-serializer case), run `bundle exec tapioca gem` (add the gem to `sorbet/tapioca/require.rb` first if it isn't required anywhere else) so `bundle exec rake` (which runs `srb tc`) has an RBI to check against.
- `ActiveRecordSerializer` types its signatures directly against `ActiveRecord::Base` (unlike the other optional serializers, which type against stdlib `String`), so a consumer's `tapioca gem` run — which force-loads and reflects every gem file, even unused classes — raises `NameError` if the `activerecord` gem isn't installed. `lib/typed/active_record_serializer.rb` fixes this with a placeholder `ActiveRecord::Base` class defined only `unless defined?`, which a real load of the gem later just reopens. Verify this class of fix by actually running `bundle exec tapioca gem` against a throwaway bundle that has `sorbet-schema` (path gem) but not `activerecord` — reading the code isn't enough, since the crash only happens inside tapioca's reflection, not at plain `require` time.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
