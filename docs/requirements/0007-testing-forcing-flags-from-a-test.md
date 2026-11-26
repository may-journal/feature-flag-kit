# 0007 Forcing flags from a test

## Why

I can force flags from a test with one helper, and the app reads them as if I typed each override.

## Measurement

app launches that read the values a test helper forced

-

app launches given overrides from a test helper

## Requirements

1. Builds launch arguments
   1. GIVEN Tester builds launch arguments with the flag off while the user's toggle is on
      1. WHEN the app launches with those arguments
         1. THEN the flagged feature stays hidden
2. Builds launch environment
   1. GIVEN Tester builds launch environment with the flag on
      1. WHEN the app launches with that environment
         1. THEN the flagged feature shows
3. Forces two flags
   1. GIVEN Tester forces two flags in one launch
      1. WHEN the app reads both flags
         1. THEN each flag holds its forced value
4. Keeps earlier arguments
   1. GIVEN Tester adds a flag override to a UI test app with arguments set
      1. WHEN the test reads the app's launch arguments
         1. THEN the earlier arguments are still there
5. Forced value wins
   1. GIVEN Tester forces a flag on in a UI test app whose arguments turn it off
      1. WHEN the app reads its launch arguments
         1. THEN the forced value wins
6. Forces an own type
   1. GIVEN Tester forces a flag of the app's own value type
      1. WHEN the app launches with those arguments
         1. THEN the flag holds the forced value
7. Keeps earlier variables
   1. GIVEN Tester forces a flag in a UI test app's environment with variables set
      1. WHEN the test reads the app's launch environment
         1. THEN the earlier variables are still there
