# 0001 Reading a flag

## Why

My app shows a feature only when its flag is on, from one definition with one default.

## Measurement

flag reads that return the user's toggle or the compiled default

-

flag reads with no override

## Requirements

1. Defaults off
   1. GIVEN Developer defines a flag that defaults off
      1. WHEN the app shows its screen
         1. THEN the flagged feature stays hidden
2. Reads the user's toggle
   1. GIVEN User turned the flag on in Settings
      1. WHEN the app shows its screen
         1. THEN the flagged feature shows
3. Reads an old key
   1. GIVEN User turned the flag on in an earlier release
   2. GIVEN under its old key
      1. WHEN the app shows its screen
         1. THEN the flagged feature shows
4. Starts each test fresh
   1. GIVEN Developer turned a flag on in one test's fresh store
      1. WHEN the next test takes a fresh store
         1. THEN the flag reads its default
5. Updates a watching screen
   1. GIVEN Developer shows a screen that watches the flag
      1. WHEN User flips the toggle
         1. THEN the screen updates
6. Follows a changed default
   1. GIVEN User set the flag back to its default
      1. WHEN a later release changes the default
         1. THEN the flag reads the new default
7. Updates across stores
   1. GIVEN User flips the toggle on a Settings screen with its own store
      1. WHEN another screen watches the flag
         1. THEN that screen updates
8. Updates on a direct write
   1. GIVEN Developer writes the toggle straight into the app's settings
      1. WHEN a screen watches the flag
         1. THEN the screen updates
