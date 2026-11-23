# 0017 Copying the flags

## Why

A tester hands me one line, and my launch starts with the flags the tester had.

## Measurement

flags away from their default that the copied line carries

-

flags away from their default

## Requirements

1. Starts from the copied line
   1. GIVEN User set two flags away from their defaults
      1. WHEN Tester launches with the store's launch arguments
         1. THEN both flags read the values the user set
2. Copies the line
   1. GIVEN User set a flag away from its default
      1. WHEN User taps Copy launch arguments on the debug screen
         1. THEN the pasteboard holds the line
         2. THEN the button says Copied
3. Disables copying with nothing to copy
   1. GIVEN User left every flag at its compiled default
      1. WHEN User reads the debug screen's buttons
         1. THEN Copy launch arguments is disabled
4. Keeps a child off under its parent
   1. GIVEN User turned a child off
   2. GIVEN User then turned its parent off
      1. WHEN Tester launches with the store's launch arguments
         1. THEN the child is still off
         2. THEN that holds once the parent is back on
