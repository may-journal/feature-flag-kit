# 0003 Flags past their day

## Why

My test suite fails once a flag outstays its expiry day, so old flags get removed.

## Measurement

flags removed by their expiry day

-

flags with an expiry day

## Requirements

- 0003.1
  - Given Developer lists a flag whose expiry day has come
    - When the expiry test runs
      - Then it names that flag
- 0003.2
  - Given Developer lists only flags that expire later
    - When the expiry test runs
      - Then it names none
- 0003.3
  - Given Developer in Tokyo on a Japanese calendar lists a flag expiring tomorrow in UTC
    - When the expiry test runs
      - Then it names none
- 0003.4
  - Given Developer lists a setting with no expiry day
    - When the expiry test runs
      - Then it names none
