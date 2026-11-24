# 0021 Flags that collide on the debug screen

## Why

The debug screen tells me why two toggles move together, even when the app has no catalog test.

## Measurement

catalog problems the debug screen names

-

catalog problems `problems()` names

## Requirements

1. Names a shared key
   1. GIVEN Developer listed two flags under one settings key
      1. WHEN Tester opens the debug screen
         1. THEN a warning names the key above both rows
2. Warns of each problem
   1. GIVEN Developer listed flags with three kinds of problem
      1. WHEN Tester reads the Catalog problems section
         1. THEN each problem is one warning
         2. THEN each warning uses the catalog test's words
3. Shows no problems for a clean catalog
   1. GIVEN Developer listed flags that do not collide
      1. WHEN Tester opens the debug screen
         1. THEN it shows no Catalog problems section
