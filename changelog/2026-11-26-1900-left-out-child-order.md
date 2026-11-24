### 2026.11.26.1900

> The debug screen copies the flags, names skipped overrides, searches and counts down expiry days.

- Feat: the debug screen copies the flags as launch arguments, quoted for a shell, and names an override the store skipped.
- Feat: the system's search field keeps the rows whose title or name holds the trimmed query, as `FlagCatalog.grouped(matching:)` does.
- Feat: `FlagCatalog.expiring(within:asOf:)` and `FlagExpiry.daysLeft(within:asOf:)` name a flag near its day, which the row counts down within 30 days.
- Docs: the README, the code view and the user journey list an off parent before the build and name the copied line.
- Docs: requirements 0016 to 0020 name their acceptances and number their GIVEN, WHEN and THEN items.
