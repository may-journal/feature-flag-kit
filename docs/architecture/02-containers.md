# Containers

A container here is a unit that runs on its own. The kit is a library, so it runs inside the app and adds no container; [03-components.md](03-components.md) shows its parts.

```mermaid
C4Container
    title Feature Flag Kit

    Person(developer, "1 Developer")

    System_Ext(app, "2 App", "Links the FeatureFlagKit library and runs it in process.")
    System_Ext(defaults, "3 UserDefaults")

    Rel(developer, app, "A")
    Rel(app, defaults, "B")

    UpdateElementStyle(developer, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(app, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
    UpdateElementStyle(defaults, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

```mermaid
C4Container
    title Legend

    Person(p, "Person", "Human actor")
    System_Ext(e, "External", "Outside our boundary")

    UpdateElementStyle(p, $bgColor="#334155", $borderColor="#1e293b", $fontColor="#ffffff")
    UpdateElementStyle(e, $bgColor="#64748b", $borderColor="#475569", $fontColor="#ffffff")
```

Numbers on nodes and letters on arrows match the callout table.

| #   | Description | Why |
| --- | --- | --- |
| 1   | The developer from the system context. | They add the kit to an app. |
| 2   | The app process the library runs in. | A library is no runnable unit of its own. |
| 3   | Holds the user's toggles on the device. | The app already keeps settings there. |
| A   | The developer builds and runs the app. | The kit is a dependency, not a tool. |
| B   | The app's linked library reads and writes toggles. | Toggles outlive a launch. |
