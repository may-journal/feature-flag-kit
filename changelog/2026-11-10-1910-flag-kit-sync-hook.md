### 2026.11.10.1910

> An app keeps its permanent settings in the kit and can sync the user's layer to another store.

- Feat: a flag defined without an expiry day gets `FlagExpiry.never`, a permanent setting that never expires.
- Feat: an enum with a `String` raw value is a `FlagValue` once it declares the conformance.
- Feat: `FlagStore.userChanges(in:)` streams a `FlagChange` with the key, new `FlagRawValue` and `FlagWriter`, from the same signal as `changes()`.
- Feat: `FlagStore.importUserValues(_:)` writes values by key as `set` would and marks each change as an import.
- Fix: a view reading a flag leaves no task waiting; the debug screen shows a choice's raw value and no setting expiry.
