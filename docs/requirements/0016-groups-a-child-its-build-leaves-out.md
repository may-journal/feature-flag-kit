# 0016 A child its build leaves out

## Why

An off parent turns its whole group off in every build, even a child that build leaves out.

## Measurement

children a build leaves out that read off under an off parent

-

children a build leaves out

## Requirements

1. Reads off under an off parent
   1. GIVEN Developer leaves a child that starts on out of production builds
      1. WHEN User turns its parent off in a production build
         1. THEN the child reads off
         2. THEN from its parent
2. Reads its default under an on parent
   1. GIVEN Developer leaves a child that starts on out of production builds
      1. WHEN a production build reads it with its parent on
         1. THEN the child reads its compiled default
         2. THEN that default is on
