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
  - Given Developer shows a view that reads the flag with `@FlagState`, and sets no store
    - When User flips the toggle elsewhere
      - Then the view updates
- 0004.3
  - Given Developer binds a Settings toggle to the flag's `$binding`
    - When User turns it on
      - Then the flag reads on, from the user's toggle
- 0004.4
  - Given Tester launches with the flag's launch argument on
    - When User opens the Settings toggle bound to `$binding`
      - Then the toggle shows the user's own choice, off
- 0004.5
  - Given Developer shows cards that each read the flag with `@FlagState`
    - When User drags them past half a page
      - Then the next page shows
- 0004.6
  - Given Developer shows a screen that hears the store's changes to a child by name
    - When User turns the parent off
      - Then the screen updates
