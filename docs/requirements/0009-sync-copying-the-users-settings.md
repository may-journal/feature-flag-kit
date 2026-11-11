# 0009 Copying the user's settings

## Why

My app copies the user's settings to another device and back, without sending an imported value back.

## Measurement

changes to the user's settings that a sync hook hears with their writer

-

changes to the user's settings

## Requirements

- 0009.1
  - Given Developer listens for changes to the user's settings
    - When User flips a toggle
      - Then the listener hears its key, new value, and that the app wrote it
- 0009.2
  - Given Developer listens for changes to the user's settings
    - When User confirms Reset all
      - Then the listener hears the key with no value
- 0009.3
  - Given Developer listens for changes to the user's settings
    - When Developer imports values from another device
      - Then the listener hears them marked as imports
- 0009.4
  - Given Developer shows a screen that watches the flag
    - When Developer imports the flag on from another device
      - Then the screen updates
