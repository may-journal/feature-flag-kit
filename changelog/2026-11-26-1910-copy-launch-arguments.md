### 2026.11.26.1910

> The debug screen copies the flags as one launch line, and requirement 0017 reads as numbered all-caps Gherkin.

- Feat: the debug screen copies the flags as launch arguments from `FlagStore.launchArguments(for:)`.
- Fix: the copied line quotes every shell character.
- Docs: the user journey and the README name the copied line.
- Docs: requirement 0017 names its acceptances and numbers its GIVEN, WHEN and THEN items.
