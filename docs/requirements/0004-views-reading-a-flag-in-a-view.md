# 0004 Reading a flag in a view

## Why

My SwiftUI view reads a flag with one property wrapper and redraws when its toggle changes.

## Measurement

views that show the flag's current value

-

views that read a flag with `@FlagState`

## Requirements

- 0004.1
  - Given User turned the flag on, and the app sets no store
    - When a view reads the flag with `@FlagState`
      - Then the flagged feature shows
- 0004.2
  - Given Developer shows a view that reads the flag with `@FlagState`
    - When User flips the toggle elsewhere
      - Then the view updates
- 0004.3
  - Given Developer binds a Settings toggle to the flag's `$binding`
    - When User turns it on
      - Then the flag reads on, from the user's toggle
