# Feature Flag Kit

Typed feature flags for Swift apps on iOS and macOS. Define each flag once and let the user turn it on in Settings. Tests force it from a launch argument or environment variable. See [Platforms](docs/architecture/04-code.md#platforms) for supported versions.

Each app keeps its own flag list. The kit supplies only the machinery: the `FeatureFlagKit` core, and `FeatureFlagKitUI` for SwiftUI.

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

A toggle set to the default, or to nil, removes its key, so it follows a later release's default. `changes()` streams the name of each flag whose toggle changed, through any store over the same settings or straight in `UserDefaults`. `FlagCatalog` is a collection, so a screen can list every flag and its title.

`resolve(_:)` returns the value and where it came from. The store asks, in order:

1. A launch argument, `-flag.onThisDay YES`.
1. An environment variable, `FLAG_ON_THIS_DAY=YES`.
1. The user's setting.
1. The compiled default.

`FlagEncoding` spells each name. Bool flags read `YES`, `NO`, `true`, `false`, `1` and `0`.

## Use in SwiftUI

Add the `FeatureFlagKitUI` product to the app target. `@FlagState` reads one `Flag` in a view:

```swift
import FeatureFlagKit
import FeatureFlagKitUI
import SwiftUI

struct MemoriesView: View {
    @FlagState(AppFlags.onThisDay) private var onThisDay

    var body: some View {
        if onThisDay { OnThisDayRow() }
        Toggle("On This Day", isOn: $onThisDay)   // writes the user's toggle
    }
}
```

`@FlagState` reads the environment's `flagStore`, which defaults to `FlagStore.live()`. The view redraws when the flag's toggle changes, from any store over the same settings. Set `.environment(\.flagStore, .isolated())` to give a preview or test its own store.

## Debug screen

`FlagDebugView(catalog:)` lists every flag in the catalog. Each row shows the title, value, the layer that set it and the expiry day.

A `Bool` flag gets a toggle for the user's layer, and an `Int` flag gets a number field. The row names that layer "user setting". Each control is disabled, with the reason, while a launch argument or environment variable sets the flag. "Reset all" asks first, then clears every user setting in the catalog.

The app decides how to open it. A hidden gesture stays in the app:

```swift
@State private var showsFlags = false

var body: some View {
    content
        .onLongPressGesture(minimumDuration: 3) { showsFlags = true }
        .sheet(isPresented: $showsFlags) {
            NavigationStack { FlagDebugView(catalog: AppFlags.catalog) }
        }
}
```

## Storybook

Each state of the debug screen is a `#Preview` in [FlagDebugView+Previews.swift](Sources/FeatureFlagKitUI/FlagDebugView+Previews.swift), in light and dark. The previews compile only in Debug builds. The demo app in [Examples/FlagDebugDemo](Examples/FlagDebugDemo/) lists them in a storybook made with [StorybookKit](https://github.com/eure/swift-storybook). Only the demo app links StorybookKit, so an app that adds this package never inherits it.

To open the storybook, generate the demo's project with XcodeGen and run it; the demo opens on the storybook. To open one story, add `--storybook "FlagDebugView: number edited"` to the scheme's Arguments.

```sh
xcodegen generate --spec Examples/FlagDebugDemo/project.yml
open Examples/FlagDebugDemo/FlagDebugDemo.xcodeproj
```

The demo signs with the owner's team, so a fork sets its own `DEVELOPMENT_TEAM` in [project.yml](Examples/FlagDebugDemo/project.yml). `make demo` builds it with no signing credentials, as CI would. `make demo-install DEVICE=<udid>` signs it, installs it on a paired device and launches it.

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
