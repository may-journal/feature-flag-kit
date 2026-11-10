# 0001 Reading a flag

## Why

My app shows a feature only when its flag is on, from one definition with one default.

## Measurement

flag reads that return the user's toggle or the compiled default

-

flag reads with no override

## Requirements

- 0001.1
  - Given Developer defines a flag that defaults off
    - When the app shows its screen
      - Then the flagged feature stays hidden
- 0001.2
  - Given User turned the flag on in Settings
    - When the app shows its screen
      - Then the flagged feature shows
- 0001.3
  - Given User turned the flag on in an earlier release, under its old key
    - When the app shows its screen
      - Then the flagged feature shows
- 0001.4
  - Given Developer turned a flag on in one test's fresh store
    - When the next test takes a fresh store
      - Then the flag reads its default
- 0001.5
  - Given Developer shows a screen that watches the flag
    - When User flips the toggle
      - Then the screen updates
- 0001.6
  - Given User set the flag back to its default
    - When a later release changes the default
      - Then the flag reads the new default
- 0001.7
  - Given User flips the toggle on a Settings screen with its own store
    - When another screen watches the flag
      - Then that screen updates
- 0001.8
  - Given Developer writes the toggle straight into the app's settings
    - When a screen watches the flag
      - Then the screen updates
