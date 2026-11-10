# User Journey

## Legend

```mermaid
flowchart TB
    subgraph types["Node types"]
        persona((1 Persona)):::persona
        screen[2 Screen]:::screen
        action(3 Action):::action
        system[(4 System)]:::system
    end

    classDef persona fill:#eef2ff,stroke:#6366f1,color:#312e81,stroke-width:2px
    classDef screen fill:#f8fafc,stroke:#64748b,color:#1e293b,stroke-width:2px
    classDef action fill:#fff7ed,stroke:#f97316,color:#9a3412,stroke-width:2px
    classDef system fill:#ecfdf5,stroke:#10b981,color:#064e3b,stroke-width:2px
```

Numbers match the callout table.

| #   | Description | Why                                      |
| --- | ----------- | ---------------------------------------- |
| 1   | Persona     | A person the system context declares.    |
| 2   | Screen      | What the person sees.                    |
| 3   | Action      | What the person does.                    |
| 4   | System      | What the product does in reply.          |

## Journey

```mermaid
flowchart TB
    developer((1 Developer)):::persona
    define(2 Define a flag with a default and expiry<br/>Req 0001):::action
    user((3 User)):::persona
    toggle(4 Turn the flag on in Settings<br/>Req 0001):::action
    tester((5 Tester)):::persona
    launch(6 Launch with an override<br/>Req 0002):::action
    resolve[(7 Store resolves the flag<br/>Req 0001 Req 0002)]:::system
    feature[8 Feature shows or hides<br/>Req 0001 Req 0002]:::screen
    expiry[(9 Expiry test names stale flags<br/>Req 0003)]:::system
    view[10 View reads the flag with @FlagState<br/>Req 0004]:::screen
    debug[11 Debug screen lists every flag and its layer<br/>Req 0005]:::screen

    developer --> define
    user --> toggle
    tester --> launch
    define --> resolve
    toggle --> resolve
    launch --> resolve
    resolve --> feature
    define --> expiry
    resolve --> view
    resolve --> debug
    debug --> toggle

    classDef persona fill:#eef2ff,stroke:#6366f1,color:#312e81,stroke-width:2px
    classDef screen fill:#f8fafc,stroke:#64748b,color:#1e293b,stroke-width:2px
    classDef action fill:#fff7ed,stroke:#f97316,color:#9a3412,stroke-width:2px
    classDef system fill:#ecfdf5,stroke:#10b981,color:#064e3b,stroke-width:2px
```

Numbers match the callout table.

| #   | Description | Type | Why |
| --- | --- | --- | --- |
| 1   | The developer. | Persona | Same person as the system context. |
| 2   | Lists a flag once, in the app's own catalog. | Action | The default lives in one place. |
| 3   | The person using the app. | Persona | Same person as the system context. |
| 4   | Flips the flag's toggle. | Action | The user's choice is saved. |
| 5   | The person testing the app. | Persona | Same person as the system context. |
| 6   | Passes a launch argument or environment variable. | Action | A run forces a flag without a rebuild. |
| 7   | Takes the launch argument, then environment, toggle and default. | System | Precedence lives in one place. |
| 8   | The flagged feature appears only when the flag is on. | Screen | What the user came to see. |
| 9   | Lists the flags past their expiry day. | System | The app's test fails until they go. |
| 10  | The view redraws when the flag's toggle changes. | Screen | A toggle shows at once. |
| 11  | Shows each flag's value, layer and expiry day, with toggles and "Reset all". | Screen | The user sees why a flag is on. |
