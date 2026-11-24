### 2026.11.26.1900

> The debug screen copies the flags, names skipped overrides and searches, and the new requirements read as numbered Gherkin.

- Feat: the debug screen copies the flags as launch arguments, in single quotes where a shell character needs them.
- Feat: `FlagStore.rejectedOverrides(in:)` and the screen name an override the store skipped, above the one that decided.
- Feat: the system's search field keeps the rows whose title or name holds the trimmed query, as `FlagCatalog.grouped(matching:)` does.
- Docs: the README, the code view and the user journey list an off parent before the build and name the copied line.
- Docs: requirements 0016 to 0019 name their acceptances and number their GIVEN, WHEN and THEN items.
