# 0018 Text the store cannot read

## Why

A mistyped override is named, so I see my typo where before another layer answered in silence.

## Measurement

unreadable overrides the store names

-

unreadable overrides in a launch

## Requirements

1. Names a launch argument
   1. GIVEN Tester launches with a number flag's launch argument that is no number
      1. WHEN Developer asks the store which overrides it rejected
         1. THEN it names the flag
         2. THEN it names the launch argument
         3. THEN it names the text
2. Names an environment variable
   1. GIVEN Tester launches with a number flag's environment variable that is no number
      1. WHEN Developer asks the store which overrides it rejected
         1. THEN it names the flag
         2. THEN it names the environment variable
         3. THEN it names the text
3. Says the argument is ignored
   1. GIVEN Tester launches with a number flag's launch argument that is no number
      1. WHEN User reads the mistyped flag on the debug screen
         1. THEN the row says the launch argument is ignored
4. Names nothing in production
   1. GIVEN Tester launches a production build with a launch argument that is no number
      1. WHEN Developer asks the store which overrides it rejected
         1. THEN it names none
