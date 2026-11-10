# Components

This splits the library in [02-containers.md](02-containers.md) into its folders. An app defines flags, then asks the store for each value, directly or through the SwiftUI views.

```mermaid
C4Component
    title FeatureFlagKit

    Person(developer, "1 Developer")

    Container_Boundary(core, "2 FeatureFlagKit") {
        Component(definitions, "3 Definitions", "Swift", "Sources/FeatureFlagKit/Definitions")
        Component(store, "4 Store", "Swift", "Sources/FeatureFlagKit/Store")
        Component(manifest, "5 Package manifest", "Swift", "Package.swift")
    }

    Container_Boundary(ui, "8 FeatureFlagKitUI") {
        Component(views, "9 Views", "SwiftUI", "Sources/FeatureFlagKitUI")
    }

    Container_Boundary(demo, "10 FlagDebugDemo") {
        Component(example, "11 Demo app", "SwiftUI", "Examples/FlagDebugDemo/FlagDebugDemo")
    }

    System_Ext(defaults, "6 UserDefaults")
    System_Ext(process, "7 Launch arguments and environment")

    Rel(developer, definitions, "A")
    Rel(store, definitions, "B")
    Rel(store, defaults, "C")
    Rel(store, process, "D")
    Rel(manifest, definitions, "E")
    Rel(developer, views, "F")
    Rel(views, store, "G")
    Rel(views, definitions, "H")
    Rel(example, views, "I")

    UpdateElementStyle(developer, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(definitions, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(store, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(manifest, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(views, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(example, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(defaults, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
    UpdateElementStyle(process, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

```mermaid
C4Component
    title Legend

    Person(p, "Person", "Human actor")
    Container_Boundary(cb, "Container boundary") {
        Component(c, "Component", "Tech", "Logical unit")
    }
    System_Ext(e, "External", "Outside our boundary")

    UpdateElementStyle(p, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(c, $bgColor="#b45309", $borderColor="#92400e", $fontColor="#ffffff")
    UpdateElementStyle(e, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

Numbers on nodes and letters on arrows match the callout table.

| #   | Description | Why |
| --- | --- | --- |
| 1   | The developer who lists the app's flags. | Each app keeps its own list. |
| 2   | The core library. | It holds no UI and no XCTest. |
| 3   | A flag, its value types, its expiry day, the catalog and the override encoding. | The definition is the one place a default lives. |
| 4   | The store, its sources and the settings it writes. | Precedence lives in one place. |
| 5   | `Package.swift`, which names both products and their platforms. | It states Swift 6, iOS 26 and macOS 26. |
| 6   | Holds the user's toggles. | Apps already keep toggles there. |
| 7   | Carries the overrides a launch sets. | Tests and manual runs need no rebuild. |
| 8   | The SwiftUI library. | SwiftUI stays out of the core. |
| 9   | The `flagStore` environment value, `@FlagState` and `FlagDebugView`. | One place for SwiftUI. |
| 10  | The example iOS app, which alone links StorybookKit. | Apps that add the kit never inherit the storybook. |
| 11  | Opens the storybook, or with `--storybook "<story name>"` one story. | Each state is seen without tapping to it. |
| A   | Defines each flag once. | One typed definition replaces repeated defaults. |
| B   | Resolves a flag from its definition. | The default is the last resort. |
| C   | Reads and writes the user's toggles. | Older keys keep working. |
| D   | Reads overrides at launch. | The launch argument wins over the environment. |
| E   | Builds each library from its sources. | Each target is its own product. |
| F   | Reads flags in views and opens the debug screen. | The app picks the gesture that opens it. |
| G   | Resolves, sets and resets flags, and hears their changes. | Views redraw when a toggle changes. |
| H   | Reads each flag's definition and the catalog. | The debug screen walks the app's list. |
| I   | Lists the previews FeatureFlagKitUI declares. | The storybook shows these previews. |
