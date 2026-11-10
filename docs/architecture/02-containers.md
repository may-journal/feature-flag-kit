# Containers

A container here is a unit that runs on its own. The kit is a library, so it runs inside the app; [03-components.md](03-components.md) shows its parts. Its one container is the example app.

```mermaid
C4Container
    title Feature Flag Kit

    Person(developer, "1 Developer")

    System_Ext(app, "2 App", "Links the FeatureFlagKit library and runs it in process.")
    System_Ext(defaults, "3 UserDefaults")

    System_Boundary(kit, "4 Feature Flag Kit") {
        Container(demo, "5 FlagDebugDemo", "Swift, SwiftUI", "Examples/FlagDebugDemo")
    }

    Rel(developer, app, "A")
    Rel(app, defaults, "B")
    Rel(developer, demo, "C")

    UpdateElementStyle(developer, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(app, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
    UpdateElementStyle(defaults, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
    UpdateElementStyle(demo, $bgColor="#0f766e", $borderColor="#115e59", $fontColor="#ffffff")
```

```mermaid
C4Container
    title Legend

    Person(p, "Person", "Human actor")
    System_Boundary(b, "System boundary") {
        Container(c, "Container", "Tech", "Runs on its own")
    }
    System_Ext(e, "External", "Outside our boundary")

    UpdateElementStyle(p, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(c, $bgColor="#0f766e", $borderColor="#115e59", $fontColor="#ffffff")
    UpdateElementStyle(e, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

Numbers on nodes and letters on arrows match the callout table.

| #   | Description | Why |
| --- | --- | --- |
| 1   | The developer from the system context. | They add the kit to an app. |
| 2   | The app process the library runs in. | A library is no runnable unit of its own. |
| 3   | Holds the user's toggles on the device. | The app already keeps settings there. |
| 4   | The repository's own code. | Only the demo runs on its own. |
| 5   | The example iOS app that shows the debug screen and its storybook. | It is the one place StorybookKit is linked. |
| A   | The developer builds and runs the app. | The kit is a dependency, not a tool. |
| B   | The app's linked library reads and writes toggles. | Toggles outlive a launch. |
| C   | The developer runs the demo, or `make screenshots` does. | The README's pictures come from it. |
