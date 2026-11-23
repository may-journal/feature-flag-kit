# 0017 Copying the flags

## Why

A tester hands me one line, and my launch starts with the flags the tester had.

## Measurement

flags away from their default that the copied line carries

-

flags away from their default

## Requirements

- 0017.1
  - Given User set two flags away from their defaults
    - When Tester launches with the store's launch arguments
      - Then both flags read the values the user set
- 0017.2
  - Given User set a flag away from its default
    - When User taps Copy launch arguments on the debug screen
      - Then the pasteboard holds the line, and the button says Copied
- 0017.3
  - Given User left every flag at its compiled default
    - When User reads the debug screen's buttons
      - Then Copy launch arguments is disabled
- 0017.4
  - Given User turned a child off and then its parent off
    - When Tester launches with the store's launch arguments
      - Then the child is still off once the parent is back on
