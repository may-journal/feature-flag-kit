# 0004 Reading a flag in a view

## Why

My SwiftUI view reads a flag with one property wrapper and redraws when its toggle changes.

## Measurement

views that show the flag's current value

-

views that read a flag with `@FlagState`

## Requirements

1. Reads the flag without a store
   1. GIVEN User turned the flag on
   2. GIVEN the app sets no store
      1. WHEN a view reads the flag with `@FlagState`
         1. THEN the flagged feature shows
2. Updates without a store
   1. GIVEN Developer shows a view that reads the flag with `@FlagState`
   2. GIVEN sets no store
      1. WHEN User flips the toggle elsewhere
         1. THEN the view updates
3. Binds a toggle
   1. GIVEN Developer binds a Settings toggle to the flag's `$binding`
      1. WHEN User turns it on
         1. THEN the flag reads on
         2. THEN from the user's toggle
4. Binding shows the user's choice
   1. GIVEN Tester launches with the flag's launch argument on
      1. WHEN User opens the Settings toggle bound to `$binding`
         1. THEN the toggle shows the user's own choice
         2. THEN off
5. Scrolls cards that read the flag
   1. GIVEN Developer shows cards that each read the flag with `@FlagState`
      1. WHEN User drags them past half a page
         1. THEN the next page shows
6. Hears a child by name
   1. GIVEN Developer shows a screen that hears the store's changes to a child by name
      1. WHEN User turns the parent off
         1. THEN the screen updates
