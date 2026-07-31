# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.
- Ruby 3.4+ unbundles former stdlib gems (e.g. `csv`) from the default load path — if a new serializer/coercer needs one, add it as an explicit `add_runtime_dependency` in the gemspec rather than assuming `require "csv"` works.
- After adding a new gem dependency, run `bundle exec tapioca gem` (add the gem to `sorbet/tapioca/require.rb` first if it isn't required anywhere else) so `bundle exec rake` (which runs `srb tc`) has an RBI to check against.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
