# 0011 Finding the build

## Why

Each build says who it is for, debug, internal or production, and the debug screen shows which one I'm running.

## Measurement

builds whose store names the environment the app declared

-

builds

## Requirements

- 0011.1
  - Given Developer sets the Info.plist key to internal
    - When the app starts
      - Then the store's environment is internal
- 0011.2
  - Given Developer sets no Info.plist key
    - When a Debug build starts
      - Then the store's environment is debug
- 0011.3
  - Given Developer passes production in code while the Info.plist key says internal
    - When the app starts
      - Then the store's environment is production
- 0011.4
  - Given Developer sets the Info.plist key to internal
    - When User opens the debug screen
      - Then it reads "Environment: internal, from Info.plist"
- 0011.5
  - Given Developer sets the Info.plist key to a build setting left unset
    - When a Debug build starts
      - Then the store's environment is production
