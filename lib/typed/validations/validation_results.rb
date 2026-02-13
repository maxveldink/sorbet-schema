It looks like I need write permission to edit the file. Could you grant permission so I can make the edits?

The changes I want to make are minimal variable renames, since the analysis confirms the code is already well-structured with no dead code or unnecessary complexity:

1. `failing_results` → `failures` (the `select(&:failure?)` already communicates filtering intent)
2. `validated_params` → `params` (scoped inside `each_with_object`, context is clear)