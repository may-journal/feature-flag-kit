# 0010 A parent and its children

## Why

One parent toggle turns a group of finer toggles off, and each keeps my choice for when it is back on.

## Measurement

child flags that read off while their parent is off and keep their own setting

-

child flags

## Requirements

1. Parent turns child off
   1. GIVEN Developer puts a flag under a parent
      1. WHEN User turns the parent off
         1. THEN the child reads off
2. Child keeps its choice
   1. GIVEN User turned a child off
      1. WHEN User cycles its parent
         1. THEN the child is still off
3. Argument beats parent
   1. GIVEN Tester launches with a child's launch argument off
      1. WHEN the parent is on
         1. THEN the child reads off
         2. THEN from the launch argument
4. Updates a child screen
   1. GIVEN Developer shows a screen that reads a child with `@FlagState`
      1. WHEN User turns the parent off
         1. THEN the screen updates
5. Disables a child toggle
   1. GIVEN User turned a parent off
      1. WHEN User opens the debug screen
         1. THEN the child's toggle is disabled
         2. THEN with the parent named as the reason
6. Lists a child under its parent
   1. GIVEN Developer lists a child apart from its parent in the catalog
      1. WHEN User opens the debug screen
         1. THEN the child's row sits right under its parent
7. Stops at one level
   1. GIVEN Developer puts a parent under a parent of its own
      1. WHEN the app defines it
         1. THEN the app stops
         2. THEN saying a group is one level deep
8. Hears a child write
   1. GIVEN Developer listens for changes to the user's settings
   2. GIVEN with the parent off
      1. WHEN User flips a child
         1. THEN the listener hears the child's own key
         2. THEN the listener hears the child's value
