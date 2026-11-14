### 2026.11.13.2100

> A flag names the builds it ships in, so a beta runs in debug and internal builds and stays off in production.

- Feat: `FlagEnvironment` is debug, internal or production, read from the `FeatureFlagEnvironment` Info.plist key, else debug or production by the `DEBUG` condition.
- Feat: `FlagStore.live(in:)` and `FlagStore.isolated(in:)` take the environment from code, for tests.
- Feat: `Flag` takes `availability:` and `environmentDefaults:`; outside its environments a flag reads its compiled default and turns its children off.
- Feat: launch arguments and environment variables apply in debug and internal only, while user settings work everywhere.
- Feat: `FlagDebugView` names the environment and hides flags the build doesn't ship; `@FlagState` and `FlagStore.isAvailable(_:)` let an app's Settings do the same.
