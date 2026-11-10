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
