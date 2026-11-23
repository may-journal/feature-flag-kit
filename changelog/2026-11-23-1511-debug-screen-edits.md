### 2026.11.23.1511

> The debug screen edits choice, decimal and text flags.

- Feat: `FlagDebugView` edits a `Double` or `String` flag in a field.
- Feat: it edits a `CaseIterable` choice flag with a button per choice, stacked when the list is long.
- Docs: requirement 0015 names the new editing, and the README lists an off parent before the build.
- Feat: the debug screen copies the flags as launch arguments from `FlagStore.launchArguments(for:)`.
- Feat: `FlagStore.rejectedOverrides(in:)` and the debug screen name an override whose text the store cannot read.
