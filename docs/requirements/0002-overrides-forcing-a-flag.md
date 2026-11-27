# 0002 Forcing a flag

## Why

I can force a flag for a test or a manual run without touching the user's own toggle.

## Measurement

flag reads that return the override passed at launch

-

flag reads with an override

## Requirements

1. Launch argument forces off
   1. GIVEN Tester launches with the launch argument off while the user's toggle is on
      1. WHEN the app shows its screen
         1. THEN the flagged feature stays hidden
2. Environment variable forces off
   1. GIVEN Tester launches with the environment variable off while the user's toggle is on
      1. WHEN the app shows its screen
         1. THEN the flagged feature stays hidden
3. Argument beats variable
   1. GIVEN Tester sets the launch argument off
   2. GIVEN Tester sets the environment variable on
      1. WHEN the app shows its screen
         1. THEN the launch argument wins
4. Source names the argument
   1. GIVEN Tester launches the app with the flag's launch argument
      1. WHEN the app asks where the flag's value came from
         1. THEN it answers the launch argument
5. Mistyped argument falls through
   1. GIVEN Tester mistypes the launch argument
   2. GIVEN Tester sets the environment variable off
      1. WHEN the app shows its screen
         1. THEN the environment variable decides
6. Mistyped variable falls through
   1. GIVEN Tester mistypes the environment variable while the user's toggle is on
      1. WHEN the app shows its screen
         1. THEN the user's toggle decides
7. Forced child names its source
   1. GIVEN Tester forces a child off
   2. GIVEN while its parent is off
      1. WHEN the debug screen shows the child's row
         1. THEN the row still names the launch argument
