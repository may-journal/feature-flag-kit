# 0009 Copying the user's settings

## Why

My app copies the user's settings to another device and back, without sending an imported value back.

## Measurement

changes to the user's settings that a sync hook hears with their writer

-

changes to the user's settings

## Requirements

1. Hears a flip
   1. GIVEN Developer listens for changes to the user's settings
      1. WHEN User flips a toggle
         1. THEN the listener hears its key
         2. THEN new value
         3. THEN that the app wrote it
2. Hears a reset
   1. GIVEN Developer listens for changes to the user's settings
      1. WHEN User confirms Reset all
         1. THEN the listener hears the key with no value
3. Hears an import
   1. GIVEN Developer listens for changes to the user's settings
      1. WHEN Developer imports values from another device
         1. THEN the listener hears them marked as imports
4. Updates on an import
   1. GIVEN Developer shows a screen that watches the flag
      1. WHEN Developer imports the flag on from another device
         1. THEN the screen updates
5. Follows a new default
   1. GIVEN Developer imports a flag's default value from another device
      1. WHEN the next release ships a new default
         1. THEN the flag reads the new default
6. Ignores odd text
   1. GIVEN User turned a flag on
      1. WHEN Developer imports text for it that is neither on nor off
         1. THEN the flag stays on
