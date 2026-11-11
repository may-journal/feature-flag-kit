### 2026.11.11.1630

> An app puts toggles under a parent, and each child reads off while the parent is off.

- Feat: a `Flag<Bool>` defined with `parent:` reads as the parent AND itself, and keeps its own setting while the parent is off.
- Feat: `FlagOrigin.parent(_:)` names the off parent, and the debug screen reads "Off, because Use suggestions is off".
- Feat: `changes()` names each watched child when its parent changes, so `@FlagState` redraws it; `$child` binds the child's own setting.
- Feat: `FlagCatalog.grouped` and the debug screen put each child, indented, under its parent, still naming an override set on it.
- Feat: a parent that has a parent of its own stops the app, so a group stays one level deep.
