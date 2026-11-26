# 0011 Finding the build

## Why

Each build says who it is for, debug, internal or production, and the debug screen shows which one I'm running.

## Measurement

builds whose store names the environment the app declared

-

builds

## Requirements

1. Reads the plist key
   1. GIVEN Developer sets the Info.plist key to internal
      1. WHEN the app starts
         1. THEN the store's environment is internal
2. Defaults to debug
   1. GIVEN Developer sets no Info.plist key
      1. WHEN a Debug build starts
         1. THEN the store's environment is debug
3. Code beats the plist
   1. GIVEN Developer passes production in code while the Info.plist key says internal
      1. WHEN the app starts
         1. THEN the store's environment is production
4. Names the plist source
   1. GIVEN Developer sets the Info.plist key to internal
      1. WHEN User opens the debug screen
         1. THEN it reads "Environment: internal
         2. THEN from Info.plist"
5. Treats an unset setting as production
   1. GIVEN Developer sets the Info.plist key to a build setting left unset
      1. WHEN a Debug build starts
         1. THEN the store's environment is production
