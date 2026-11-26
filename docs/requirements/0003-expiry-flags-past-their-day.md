# 0003 Flags past their day

## Why

My test suite fails once a flag outstays its expiry day, so old flags get removed.

## Measurement

flags removed by their expiry day

-

flags with an expiry day

## Requirements

1. Names an expired flag
   1. GIVEN Developer lists a flag whose expiry day has come
      1. WHEN the expiry test runs
         1. THEN it names that flag
2. Passes later expiries
   1. GIVEN Developer lists only flags that expire later
      1. WHEN the expiry test runs
         1. THEN it names none
3. Reads the day in UTC
   1. GIVEN Developer in Tokyo on a Japanese calendar lists a flag expiring tomorrow in UTC
      1. WHEN the expiry test runs
         1. THEN it names none
4. Skips a missing expiry
   1. GIVEN Developer lists a setting with no expiry day
      1. WHEN the expiry test runs
         1. THEN it names none
