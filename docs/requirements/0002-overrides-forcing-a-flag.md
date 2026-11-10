# 0002 Forcing a flag

## Why

I can force a flag for a test or a manual run without touching the user's own toggle.

## Measurement

flag reads that return the override passed at launch

-

flag reads with an override

## Requirements

- 0002.1
  - Given Tester launches with the launch argument off while the user's toggle is on
    - When the app shows its screen
      - Then the flagged feature stays hidden
- 0002.2
  - Given Tester launches with the environment variable off while the user's toggle is on
    - When the app shows its screen
      - Then the flagged feature stays hidden
- 0002.3
  - Given Tester sets the launch argument off and the environment variable on
    - When the app shows its screen
      - Then the launch argument wins
- 0002.4
  - Given Tester launches the app with the flag's launch argument
    - When the app asks where the flag's value came from
      - Then it answers the launch argument
