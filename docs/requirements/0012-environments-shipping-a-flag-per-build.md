# 0012 Shipping a flag per build

## Why

A beta runs in debug and internal builds and stays off in production, where only my own settings change a flag.

## Measurement

flag reads that follow the flag's environments and the build's override rule

-

flag reads

## Requirements

- 0012.1
  - Given Developer ships a flag in debug and internal only, and User turned it on
    - When a production build reads it
      - Then it reads its default
- 0012.2
  - Given Developer starts a flag on in internal builds
    - When an internal build reads it
      - Then it reads on
- 0012.3
  - Given Tester launches a production build with the flag's launch argument and variable on
    - When the app reads the flag
      - Then it reads off
- 0012.4
  - Given Tester launches an internal build with the flag's launch argument on
    - When the app reads the flag
      - Then it reads on, from the launch argument
- 0012.5
  - Given Developer starts a flag on in production builds
    - When User turns it off in a production build
      - Then it reads off
- 0012.6
  - Given Developer ships a flag in debug and internal only
    - When User opens the debug screen in a production build
      - Then the flag has no row
- 0012.7
  - Given Developer shows a Settings screen that reads a debug and internal flag with `@FlagState`
    - When a production build shows it
      - Then the flag's toggle is hidden
- 0012.8
  - Given Developer ships a parent in debug only, with a child in every build
    - When a production build reads the child
      - Then it reads off
