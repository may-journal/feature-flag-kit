# Feature Flag Kit

Typed feature flags for Swift apps on iOS and macOS. Define each flag once and let the user turn it on in Settings. Tests force it from a launch argument or environment variable. See [Platforms](docs/architecture/04-code.md#platforms) for supported versions.

Each app keeps its own flag list. The kit supplies only the machinery.

## Define flags

List the app's flags in one place, each with a name, compiled default, title and expiry day:

```swift
import FeatureFlagKit

enum AppFlags {
    static let onThisDay = Flag(
        "onThisDay", default: false, title: "On This Day",
        expires: FlagExpiry(year: 2027, month: 6, day: 1),
        legacySettingsKey: "beta.onThisDay")

    static let catalog = FlagCatalog([onThisDay])
}
```

A toggle lives in `UserDefaults` under `flag.<name>`. Pass `legacySettingsKey` to keep a key an earlier release already wrote, so the user's choice carries over.

## Read and toggle

```swift
let flags = FlagStore.live()
if flags[AppFlags.onThisDay] { showOnThisDay() }
flags.set(true, for: AppFlags.onThisDay)   // the user's Settings toggle
flags.reset(AppFlags.onThisDay)            // back to the default
```

A toggle set to the default, or to nil, removes its key, so it follows a later release's default. `changes()` streams the name of each flag whose toggle changed. `FlagCatalog` is a collection, so a screen can list every flag and its title.

`resolve(_:)` returns the value and where it came from. The store asks, in order:

1. A launch argument, `-flag.onThisDay YES`.
1. An environment variable, `FLAG_ON_THIS_DAY=YES`.
1. The user's toggle.
1. The compiled default.

`FlagEncoding` spells each name. Bool flags read `YES`, `NO`, `true`, `false`, `1` and `0`.

## Test

Give each test a fresh store, with toggles held in memory. Pass arguments or environment to force a flag:

```swift
let flags = FlagStore.isolated(arguments: FlagEncoding.arguments(AppFlags.onThisDay, true))
```

Add one test so a flag cannot outstay its expiry day:

```swift
@Test func noFlagIsPastItsDay() {
    #expect(AppFlags.catalog.expired().map(\.name) == [])
}
```

## Docs

- [docs/architecture/](docs/architecture/): the design.
- [docs/requirements/](docs/requirements/): what the kit promises, each with its test.
- [Plans](https://github.com/may-journal/feature-flag-kit/issues?q=label%3APlan): work in flight, tracked as GitHub Issues.

## License

MIT. See [LICENSE](LICENSE).
