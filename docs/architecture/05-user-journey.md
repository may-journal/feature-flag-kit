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
    define(2 Define a flag or setting with a default<br/>Req 0001 Req 0008):::action
    user((3 User)):::persona
    toggle(4 Turn the flag on in Settings<br/>Req 0001):::action
    tester((5 Tester)):::persona
    launch(6 Launch with an override<br/>Req 0002 Req 0007):::action
    resolve[(7 Store resolves the flag<br/>Req 0001 Req 0002)]:::system
    feature[8 Feature shows or hides<br/>Req 0001 Req 0002]:::screen
    expiry[(9 Expiry test names stale flags<br/>Req 0003)]:::system
    view[10 View reads the flag with @FlagState<br/>Req 0004]:::screen
    debug[11 Debug screen lists every flag and its layer<br/>Req 0005 Req 0006]:::screen
    choose(12 Pick a choice for a setting<br/>Req 0008):::action
    sync[(13 Sync hook hears the user's changes and imports values<br/>Req 0009)]:::system
    group(14 Turn off a parent toggle<br/>Req 0010):::action
    environment(15 Declare the build's environment and each flag's builds<br/>Req 0011 Req 0012):::action

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
    user --> choose
    choose --> resolve
    toggle --> sync
    sync --> view
    user --> group
    group --> resolve
    developer --> environment
    environment --> resolve

    classDef persona fill:#eef2ff,stroke:#6366f1,color:#312e81,stroke-width:2px
    classDef screen fill:#f8fafc,stroke:#64748b,color:#1e293b,stroke-width:2px
    classDef action fill:#fff7ed,stroke:#f97316,color:#9a3412,stroke-width:2px
    classDef system fill:#ecfdf5,stroke:#10b981,color:#064e3b,stroke-width:2px
```

Numbers match the callout table.

| #   | Description | Type | Why |
| --- | --- | --- | --- |
| 1   | The developer. | Persona | Same person as the system context. |
| 2   | Lists a flag once, in the app's own catalog, with an expiry day unless it is a permanent setting. | Action | The default lives in one place. |
| 3   | The person using the app. | Persona | Same person as the system context. |
| 4   | Flips the flag's toggle. | Action | The user's choice is saved. |
| 5   | The person testing the app. | Persona | Same person as the system context. |
| 6   | Passes a launch argument or environment variable, by hand or from `FlagLaunch`. | Action | A run forces a flag without a rebuild. |
| 7   | Checks the flag ships in this build, then takes the launch argument, variable, toggle and defaults. | System | Precedence lives in one place. |
| 8   | The flagged feature appears only when the flag is on. | Screen | What the user came to see. |
| 9   | Lists the flags past their expiry day, never a setting without one. | System | The app's test fails until they go. |
| 10  | The view redraws when the flag's toggle changes. | Screen | A toggle shows at once. |
| 11  | Shows each flag's value, layer and expiry day, with toggles, number fields and a confirmed "Reset all". | Screen | The user sees why a flag is on. |
| 12  | Picks one of a setting's choices, an enum with a `String` raw value. | Action | A setting needs no code per choice. |
| 13  | Reports each change to the user's layer with its writer, and writes imported values as imports. | System | An app syncs settings without sending imports back. |
| 14  | Turns off a parent, which turns its children off and keeps their own settings. | Action | One switch covers a group and loses no choice. |
| 15  | Sets the Info.plist key per build configuration and lists each flag's environments. | Action | A beta runs for testers and stays off in production. |
