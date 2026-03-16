---
description: Implement a Pencil (.pen) design in Flutter with theme-driven typography and light/dark parity
---

Use this workflow whenever a task references a design from `pencil-designs/` or any `.pen` file.

### Steps to follow:

1. **Locate and inspect the design source**:
   - Confirm the target `.pen` file and the specific screen/component to implement.
   - Identify whether the design provides two variants (light and dark).
   - Map each visual element to existing Flutter widgets and theme tokens.

2. **Check for reusable UI patterns first**:
   - Search in `lib/presentation/widgets/` and `lib/presentation/screens/widgets/` for existing components.
   - Reuse existing widgets before creating new ones.

3. **Implement structure and spacing first**:
   - Build layout hierarchy (containers, sections, cards, actions) before fine styling.
   - Keep widgets split into private sub-widgets when the build method grows.

4. **Typography must be theme-driven**:
   - Use `Theme.of(context).textTheme` (and existing semantic theme tokens) for text styles.
   - Do **NOT** hardcode `fontFamily: 'Inter'` in widget-level `TextStyle`.
   - Only use explicit `fontFamily` when a design requires a different, intentional typeface and that requirement is documented in the PR/issue.

5. **Implement visual parity for light and dark modes**:
   - If the Pencil deliverable includes both themes, implement both in the same change.
   - Ensure all colors come from `ThemeExtension`/theme tokens and render correctly in both modes.
   - If a needed token is missing, add or extend the relevant `ThemeExtension` and wire values in `app_theme.dart` for light and dark.

6. **Compliance checks before completion**:
   - Run the `check-theme-compliance` workflow.
   - Search for forbidden typography hardcoding:
     - `fontFamily:\s*['\"]Inter['\"]`
   - Validate there are no new hardcoded colors (`0x...` or direct `Colors.` usage for UI styling).

7. **Quality gates**:
   - Run `dart format lib/ test/`.
   - Run `flutter analyze`.
   - Run relevant tests (or `flutter test` when scope is broad).

### Completion checklist

- [ ] `.pen` design is mapped to Flutter UI using existing patterns where possible.
- [ ] No unnecessary widget-level `fontFamily: 'Inter'` declarations were introduced.
- [ ] Theme-based typography is used consistently.
- [ ] Light and dark variants are both implemented when required by the design.
- [ ] Theme compliance, formatting, analysis, and tests were executed.
