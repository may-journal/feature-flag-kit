# 0015 Editing every value

## Why

The debug screen changes a choice, a decimal and a text flag, so I try another value with no relaunch.

## Measurement

value types the debug screen lets the user edit

-

value types the kit ships

## Requirements

1. Picks a choice
   1. GIVEN User opens the debug screen
      1. WHEN User picks another choice for a choice flag
         1. THEN the row shows that choice
         2. THEN from the user's setting
2. Types a decimal
   1. GIVEN User opens the debug screen
      1. WHEN User types a decimal for a decimal flag
         1. THEN the row shows that number
         2. THEN from the user's setting
3. Types text
   1. GIVEN User opens the debug screen
      1. WHEN User types text for a text flag
         1. THEN the row shows that text
         2. THEN from the user's setting
4. Disables a forced decimal
   1. GIVEN Tester launches with a decimal flag's launch argument
      1. WHEN the debug screen shows that flag's row
         1. THEN the field is disabled
         2. THEN with the reason beside it
5. Picks the last of many
   1. GIVEN Developer lists a choice flag with eight choices
      1. WHEN User picks the last choice on the debug screen
         1. THEN the row shows that choice
         2. THEN from the user's setting
