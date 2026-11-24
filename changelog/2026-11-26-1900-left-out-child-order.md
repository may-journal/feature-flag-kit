### 2026.11.26.1900

> The debug screen copies the flags, names skipped overrides, searches, counts down expiry days and warns of catalog problems.

- Feat: the debug screen copies the flags as launch arguments, names a skipped override and searches.
- Feat: `FlagCatalog.expiring(within:asOf:)` and `FlagExpiry.daysLeft(within:asOf:)` name a flag near its day, which the row counts down.
- Feat: a "Catalog problems" section warns of each collision `problems()` names, and twin flags keep their row identities through a search.
- Docs: the README, the code view and the user journey list an off parent before the build and name the copied line.
- Docs: requirements 0016 to 0021 name their acceptances and number their GIVEN, WHEN and THEN items.
