---
description: Translate missing messages indicated in untranslated_messages.json
---
This workflow allows automatically processing and adding missing translations in the project's `.arb` files, based on the report generated in `untranslated_messages.json`.

### Steps to follow:

1. **Analyze missing messages**:
   Read the `untranslated_messages.json` file in the project root. This file contains an object where keys are language codes (ar, ca, de, etc.) and values are lists of translation keys missing in that language.

2. **Obtain reference values**:
   Look for the identified keys in the `lib/core/l10n/app_en.arb` file (the base language) to understand the context and obtain the original values, as well as any associated metadata (placeholders, descriptions, etc.).

3. **Generate translations**:
   For each language and each key:
   - Translate the value to the target language maintaining the meaning and style.
   - If the key has metadata (e.g., `@key`), ensure it is also included in the target file if it's not present.
   - Respect placeholders like `{count}`, `{name}`, etc.

4. **Update ARB files**:
   - Locate the corresponding file (`lib/core/l10n/app_<lang>.arb`).
   - Add the new entries at the end of the JSON object.
   - **IMPORTANT**: Ensure a comma is added to the line preceding the new entry and that the file remains a valid JSON.

5. **Completion**:
   Once all translations are processed, clear the `untranslated_messages.json` file, leaving an empty object `{}` to indicate no further messages are pending.
