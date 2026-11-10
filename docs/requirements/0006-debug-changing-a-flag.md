# 0006 Changing a flag

## Why

The debug screen lets me type a number for a number flag, and asks before "Reset all" clears my settings, never an override.

## Measurement

number flags the debug screen lets the user edit

-

number flags in the app's catalog

## Requirements

- 0006.1
  - Given User opens the debug screen
    - When User types a new number for a number flag
      - Then the row shows that number, from the user's setting
- 0006.2
  - Given User set a flag away from its default
    - When User cancels the Reset all confirmation
      - Then the flag keeps the user's setting
- 0006.3
  - Given User set two flags away from their defaults
    - When User confirms Reset all
      - Then every flag shows its default
- 0006.4
  - Given Tester launches with a flag's launch argument on
    - When User confirms Reset all
      - Then that flag stays on, from the launch argument
