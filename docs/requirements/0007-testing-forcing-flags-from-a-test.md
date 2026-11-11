# 0007 Forcing flags from a test

## Why

I can force flags from a test with one helper, and the app reads them as if I typed each override.

## Measurement

app launches that read the values a test helper forced

-

app launches given overrides from a test helper

## Requirements

- 0007.1
  - Given Tester builds launch arguments with the flag off while the user's toggle is on
    - When the app launches with those arguments
      - Then the flagged feature stays hidden
- 0007.2
  - Given Tester builds launch environment with the flag on
    - When the app launches with that environment
      - Then the flagged feature shows
- 0007.3
  - Given Tester forces two flags in one launch
    - When the app reads both flags
      - Then each flag holds its forced value
- 0007.4
  - Given Tester adds a flag override to a UI test app with arguments set
    - When the test reads the app's launch arguments
      - Then the earlier arguments are still there
- 0007.5
  - Given Tester forces a flag on in a UI test app whose arguments turn it off
    - When the app reads its launch arguments
      - Then the forced value wins
- 0007.6
  - Given Tester forces a flag of the app's own value type
    - When the app launches with those arguments
      - Then the flag holds the forced value
- 0007.7
  - Given Tester forces a flag in a UI test app's environment with variables set
    - When the test reads the app's launch environment
      - Then the earlier variables are still there
