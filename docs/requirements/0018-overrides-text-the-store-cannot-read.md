# 0018 Text the store cannot read

## Why

A mistyped override is named, so I see my typo where before another layer answered in silence.

## Measurement

unreadable overrides the store names

-

unreadable overrides in a launch

## Requirements

- 0018.1
  - Given Tester launches with a number flag's launch argument that is no number
    - When Developer asks the store which overrides it rejected
      - Then it names the flag, the launch argument and the text
- 0018.2
  - Given Tester launches with a number flag's environment variable that is no number
    - When Developer asks the store which overrides it rejected
      - Then it names the flag, the environment variable and the text
- 0018.3
  - Given Tester launches with a number flag's launch argument that is no number
    - When User reads the mistyped flag on the debug screen
      - Then the row says the launch argument is ignored
- 0018.4
  - Given Tester launches a production build with a launch argument that is no number
    - When Developer asks the store which overrides it rejected
      - Then it names none
