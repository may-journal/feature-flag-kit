# 0008 Choosing from a list

## Why

My app keeps a setting that is one of a list of choices, defined once, with no code per choice.

## Measurement

settings with a list of choices that read the user's choice

-

settings with a list of choices

## Requirements

1. Picks a choice
   1. GIVEN Developer shows a screen with a setting's list of choices
      1. WHEN User picks a choice
         1. THEN the screen shows that choice
2. Reads an old key
   1. GIVEN User picked a choice in an earlier release
   2. GIVEN under its old key
      1. WHEN the app shows the setting's screen
         1. THEN the screen shows that choice
3. Forces a choice
   1. GIVEN Tester launches with a choice's launch argument
      1. WHEN the app shows the setting's screen
         1. THEN the screen shows that choice
