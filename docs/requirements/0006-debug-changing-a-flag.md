# 0006 Changing a flag

## Why

The debug screen lets me type a number for a number flag, and asks before "Reset all" clears my settings, never an override.

## Measurement

number flags the debug screen lets the user edit

-

number flags in the app's catalog

## Requirements

1. Types a number
   1. GIVEN User opens the debug screen
      1. WHEN User types a new number for a number flag
         1. THEN the row shows that number
         2. THEN from the user's setting
2. Cancels Reset all
   1. GIVEN User set a flag away from its default
      1. WHEN User cancels the Reset all confirmation
         1. THEN the flag keeps the user's setting
3. Resets every flag
   1. GIVEN User set two flags away from their defaults
      1. WHEN User confirms Reset all
         1. THEN every flag shows its default
4. Keeps a forced flag
   1. GIVEN Tester launches with a flag's launch argument on
      1. WHEN User confirms Reset all
         1. THEN that flag stays on
         2. THEN from the launch argument
5. Keeps an unshipped setting
   1. GIVEN User saved a setting for a flag this build doesn't ship
      1. WHEN User confirms Reset all
         1. THEN that saved setting stays
