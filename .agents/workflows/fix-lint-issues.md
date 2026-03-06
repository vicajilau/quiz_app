---
description: Fix lint and static analysis issues reported by flutter analyze
---

This workflow allows systematically fixing all lint and static analysis warnings/errors in the project.

### Steps to follow:

1. **Run the analyzer**:
   Execute `flutter analyze` from the project root and capture the full output. Each issue follows the format:
   ```
   info - lib/path/to/file.dart:42:10 - Message describing the issue - rule_name
   ```

2. **Categorize issues by severity**:
   Address issues in this priority order:
   - `error` — compilation or critical issues (fix first)
   - `warning` — potential bugs or deprecated API usage
   - `info` — style and best-practice suggestions

3. **Group by rule**:
   When multiple files have the same lint rule violation, fix them together for consistency. Common rules include:
   - `prefer_const_constructors` — add `const` keyword to constructors
   - `prefer_const_literals_to_create_immutables` — use `const` for immutable collection literals
   - `unused_import` — remove unused imports
   - `unused_local_variable` / `unused_field` — remove or use the variable
   - `deprecated_member_use` — migrate to the replacement API
   - `avoid_print` — replace with `printInDebug(...)` (project utility in `lib/core/debug_print.dart`)
   - `sort_child_properties_last` — move `child` / `children` to the end of widget constructor arguments
   - `use_super_parameters` — convert to `super.key` syntax
   - `unnecessary_this` — remove redundant `this.` prefix

4. **Apply fixes**:
   For each file:
   - Read the file to understand the context around the reported line.
   - Apply the minimal change needed to resolve the issue.
   - Do not introduce unrelated changes or refactors.
   - Preserve the existing license header and import order.

5. **Auto-fixable rules**:
   Some issues can be resolved in bulk with:
   ```bash
   dart fix --apply
   ```
   Run this first to handle trivial fixes automatically, then address remaining issues manually.

6. **Format after fixing**:
   Run `dart format lib/ test/` to ensure consistent formatting after all changes.

7. **Verify**:
   Run `flutter analyze` again and confirm zero issues remain. If new issues appeared from the fixes, repeat from step 1.
