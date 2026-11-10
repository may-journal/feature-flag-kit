# 0005 Seeing every flag

## Why

One debug screen lists every flag, says why each is on or off, and lets me flip or reset them.

## Measurement

flags the debug screen shows with their value, layer and expiry day

-

flags in the app's catalog

## Requirements

- 0005.1
  - Given Developer opens the debug screen on the app's catalog
    - When it shows
      - Then each flag shows its title, value and expiry day
- 0005.2
  - Given Tester launches with the flag's launch argument on
    - When User opens the debug screen
      - Then the flag's row names the launch argument
- 0005.3
  - Given User opens the debug screen
    - When User turns a flag's toggle on
      - Then the row shows it on, from the user's toggle
- 0005.4
  - Given Tester launches with the flag's launch argument on
    - When User opens the debug screen
      - Then the toggle is disabled, with the reason beside it
- 0005.5
  - Given User set two flags away from their defaults
    - When User taps Reset all
      - Then every flag shows its default
- 0005.6
  - Given User reads the debug screen with VoiceOver
    - When VoiceOver reaches a flag
      - Then it hears the title, value, layer and expiry day in order
- 0005.7
  - Given Developer lists a flag of their own type in the catalog
    - When User opens the debug screen
      - Then its row shows the title and says the value is unknown
