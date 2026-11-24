# 0015 Editing every value

## Why

The debug screen changes a choice, a decimal and a text flag, so I try another value with no relaunch.

## Measurement

value types the debug screen lets the user edit

-

value types the kit ships

## Requirements

- 0015.1
  - Given User opens the debug screen
    - When User picks another choice for a choice flag
      - Then the row shows that choice, from the user's setting
- 0015.2
  - Given User opens the debug screen
    - When User types a decimal for a decimal flag
      - Then the row shows that number, from the user's setting
- 0015.3
  - Given User opens the debug screen
    - When User types text for a text flag
      - Then the row shows that text, from the user's setting
- 0015.4
  - Given Tester launches with a decimal flag's launch argument
    - When the debug screen shows that flag's row
      - Then the field is disabled, with the reason beside it
- 0015.5
  - Given Developer lists a choice flag with eight choices
    - When User picks the last choice on the debug screen
      - Then the row shows that choice, from the user's setting
