# 0012 Shipping a flag per build

## Why

A beta runs in debug and internal builds and stays off in production, where only my own settings change a flag.

## Measurement

flag reads that follow the flag's environments and the build's override rule

-

flag reads

## Requirements

1. Hides a flag in production
   1. GIVEN Developer ships a flag in non-production builds only
   2. GIVEN User turned it on
      1. WHEN a production build reads it
         1. THEN it reads its default
2. Starts on in internal
   1. GIVEN Developer starts a flag on in internal builds
      1. WHEN an internal build reads it
         1. THEN it reads on
3. Production ignores forcing
   1. GIVEN Tester launches a production build with the flag's launch argument on
   2. GIVEN the flag's environment variable is on
      1. WHEN the app reads the flag
         1. THEN it reads off
4. Internal takes forcing
   1. GIVEN Tester launches an internal build with the flag's launch argument on
      1. WHEN the app reads the flag
         1. THEN it reads on
         2. THEN from the launch argument
5. Production toggles off
   1. GIVEN Developer starts a flag on in production builds
      1. WHEN User turns it off in a production build
         1. THEN it reads off
6. Hides the row
   1. GIVEN Developer ships a flag in non-production builds only
      1. WHEN User opens the debug screen in a production build
         1. THEN the flag has no row
7. Hides the toggle
   1. GIVEN Developer shows a Settings screen that reads a non-production flag with `@FlagState`
      1. WHEN a production build shows it
         1. THEN the flag's toggle is hidden
8. Hides a child with its parent
   1. GIVEN Developer ships a parent in debug only
   2. GIVEN with a child in every build
      1. WHEN a production build reads the child
         1. THEN it reads off
