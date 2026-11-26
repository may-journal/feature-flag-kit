# 0013 A page for every acceptance

## Why

The storybook shows each acceptance on its own page, so I see a state without tapping my way to it.

## Measurement

acceptances with a storybook page named by their ID

-

acceptances in the requirement docs

## Requirements

1. Flips a feature page
   1. GIVEN Developer opens a feature page on a fresh store
      1. WHEN User flips its toggle
         1. THEN the page shows the feature
         2. THEN from the user's setting
2. Lists a listener write
   1. GIVEN Developer opens a listener page
      1. WHEN the page makes its one write
         1. THEN the page lists the key
         2. THEN the value
         3. THEN the writer
3. Names an expired flag
   1. GIVEN Developer opens an expiry page on a flag's expiry day
      1. WHEN it shows
         1. THEN the page names that flag as past its day
4. Shows light and dark on one page
   1. GIVEN Developer opens the storybook page of the debug screen
      1. WHEN the page draws the screen
         1. THEN it labels a light column
         2. THEN it labels a dark column
