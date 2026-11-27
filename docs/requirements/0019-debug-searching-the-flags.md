# 0019 Searching the flags

## Why

I type part of a flag's title or name, and its row is the one left on the debug screen.

## Measurement

searches whose matching flags are the rows left

-

searches typed on the debug screen

## Requirements

1. Shows each match
   1. GIVEN User typed "day" and a space in the debug screen's search
      1. WHEN User reads the rows
         1. THEN each matching flag shows
         2. THEN a matching child shows under its parent
2. Matches a name
   1. GIVEN User typed SUGGESTIONS as part of three flags' names
      1. WHEN User reads the rows
         1. THEN both children show by name under their parent
         2. THEN no other row shows
3. Resets with no match
   1. GIVEN User typed text no flag holds
      1. WHEN User taps Reset all and confirms
         1. THEN the screen says No flags match
         2. THEN every flag resets
4. Shows every row again
   1. GIVEN User searched and matched no flag
      1. WHEN User clears the search
         1. THEN every flag's row shows again
