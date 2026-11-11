# 0010 A parent and its children

## Why

One parent toggle turns a group of finer toggles off, and each keeps my choice for when it is back on.

## Measurement

child flags that read off while their parent is off and keep their own setting

-

child flags

## Requirements

- 0010.1
  - Given Developer puts a flag under a parent
    - When User turns the parent off
      - Then the child reads off
- 0010.2
  - Given User turned a child off
    - When User turns its parent off and back on
      - Then the child is still off
- 0010.3
  - Given Tester launches with a child's launch argument off
    - When the parent is on
      - Then the child reads off, from the launch argument
- 0010.4
  - Given Developer shows a screen that reads a child with `@FlagState`
    - When User turns the parent off
      - Then the screen updates
- 0010.5
  - Given User turned a parent off
    - When User opens the debug screen
      - Then the child's toggle is disabled, with the parent named as the reason
- 0010.6
  - Given Developer lists a child apart from its parent in the catalog
    - When User opens the debug screen
      - Then the child's row sits right under its parent
- 0010.7
  - Given Developer puts a parent under a parent of its own
    - When the app defines it
      - Then the app stops, saying a group is one level deep
- 0010.8
  - Given Developer listens for changes to the user's settings, with the parent off
    - When User flips a child
      - Then the listener hears the child's own key and value
