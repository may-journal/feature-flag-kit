### 2026.11.10.1910

> An app keeps its permanent settings in the kit and can sync the user's layer to another store.

- Feat: the expiry day is optional, also on `AnyFlag`, and `FlagCatalog.expired(asOf:)` never names a setting without one.
- Feat: an enum with a `String` raw value is a `FlagValue` once it declares the conformance.
- Feat: `FlagStore.userChanges(in:)` streams a `FlagChange` with the key, new `FlagRawValue` and `FlagWriter`, from the same signal as `changes()`.
- Feat: `FlagStore.importUserValues(_:)` writes values by settings key and marks each change as an import.
- Fix: the debug screen shows a choice by its raw value and no expiry line for a setting.
