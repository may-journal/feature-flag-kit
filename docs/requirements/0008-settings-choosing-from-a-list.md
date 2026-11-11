# 0008 Choosing from a list

## Why

My app keeps a setting that is one of a list of choices, defined once, with no code per choice.

## Measurement

settings with a list of choices that read the user's choice

-

settings with a list of choices

## Requirements

- 0008.1
  - Given Developer shows a screen with a setting's list of choices
    - When User picks a choice
      - Then the screen shows that choice
- 0008.2
  - Given User picked a choice in an earlier release, under its old key
    - When the app shows the setting's screen
      - Then the screen shows that choice
- 0008.3
  - Given Tester launches with a choice's launch argument
    - When the app shows the setting's screen
      - Then the screen shows that choice
