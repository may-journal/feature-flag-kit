# 0016 A child its build leaves out

## Why

An off parent turns its whole group off in every build, even a child that build leaves out.

## Measurement

children a build leaves out that read off under an off parent

-

children a build leaves out

## Requirements

- 0016.1
  - Given Developer leaves a child that starts on out of production builds
    - When User turns its parent off in a production build
      - Then the child reads off, because of its parent
- 0016.2
  - Given Developer leaves a child that starts on out of production builds
    - When a production build reads it with its parent on
      - Then the child reads its compiled default, on
