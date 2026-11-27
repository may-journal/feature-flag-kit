# 0020 Flags near their day

## Why

A flag near its expiry day is named ahead, so I remove it before the expiry test fails.

## Measurement

flags removed before their expiry day

-

flags that reached their expiry day

## Requirements

1. Names a flag within the window
   1. GIVEN Developer listed a flag that expires in 12 days
      1. WHEN Developer asks the catalog for flags expiring within 14 days
         1. THEN the catalog names that flag
2. Leaves out a flag past its day
   1. GIVEN Developer listed a flag past its day
   2. GIVEN Developer listed a permanent setting
      1. WHEN Developer asks for flags expiring within 14 days
         1. THEN the catalog names neither
3. Counts days in UTC
   1. GIVEN Developer runs the test in Tokyo early on a morning
      1. WHEN Developer counts the days to a flag's expiry day
         1. THEN the count follows the UTC day
4. Counts down 12 days
   1. GIVEN User opens the debug screen 12 days before a flag's day
      1. WHEN User reads the flag's row
         1. THEN it says Expires 2027-03-01
         2. THEN it says in 12 days
5. Counts down 1 day
   1. GIVEN User opens the debug screen the day before a flag's day
      1. WHEN User reads the flag's row
         1. THEN it says in 1 day
6. Shows the day alone
   1. GIVEN User opens the debug screen 31 days before a flag's day
      1. WHEN User reads the flag's row
         1. THEN it shows the day alone
