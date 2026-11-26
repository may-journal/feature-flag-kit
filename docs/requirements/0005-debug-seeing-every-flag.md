# 0005 Seeing every flag

## Why

One debug screen lists every flag, says why each is on or off, and lets me flip them.

## Measurement

flags the debug screen shows with their value, layer and expiry day

-

flags in the app's catalog

## Requirements

1. Shows every flag
   1. GIVEN Developer opens the debug screen on the app's catalog
      1. WHEN it shows
         1. THEN each flag shows its title
         2. THEN value
         3. THEN expiry day
2. Names a launch argument
   1. GIVEN Tester launches with the flag's launch argument on
      1. WHEN User opens the debug screen
         1. THEN the flag's row names the launch argument
3. Shows the user's toggle
   1. GIVEN User opens the debug screen
      1. WHEN User turns a flag's toggle on
         1. THEN the row shows it on
         2. THEN from the user's setting
4. Disables a forced toggle
   1. GIVEN Tester launches with the flag's launch argument on
      1. WHEN User opens the debug screen
         1. THEN the toggle is disabled
         2. THEN with the reason beside it
5. Removed in 2026.11.26.1120: Reset all moved to requirement 0006
6. Reads out each flag
   1. GIVEN User reads the debug screen with VoiceOver
      1. WHEN VoiceOver reaches a flag
         1. THEN it hears the title
         2. THEN value
         3. THEN layer
         4. THEN expiry day in order
7. Shows an unknown type
   1. GIVEN Developer lists a flag of their own type in the catalog
      1. WHEN User opens the debug screen
         1. THEN its row shows the title and says the value is unknown
8. Disables a forced number
   1. GIVEN Tester launches with a number flag's launch argument
      1. WHEN User opens the debug screen
         1. THEN the number field is disabled
         2. THEN with the reason beside it
9. Shows no missing expiry
   1. GIVEN Developer lists a setting with no expiry day
      1. WHEN User opens the debug screen
         1. THEN its row shows no expiry day
