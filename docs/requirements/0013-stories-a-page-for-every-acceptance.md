# 0013 A page for every acceptance

## Why

The storybook shows each acceptance on its own page, so I see a state without tapping my way to it.

## Measurement

acceptances with a storybook page named by their ID

-

acceptances in the requirement docs

## Requirements

- 0013.1
  - Given Developer opens a feature page on a fresh store
    - When User flips its toggle
      - Then the page shows the feature, from the user's setting
- 0013.2
  - Given Developer opens a listener page
    - When the page makes its one write
      - Then the page lists the key, the value and the writer
- 0013.3
  - Given Developer opens an expiry page on a flag's expiry day
    - When it shows
      - Then the page names that flag as past its day
