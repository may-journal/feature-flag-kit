# 0014 Flags that collide

## Why

One test names every pair of flags that would share a toggle, an override or a missing parent, before a user meets it.

## Measurement

kinds of collision the catalog names

-

kinds of collision a catalog can hold

## Requirements

1. Names a duplicate name
   1. GIVEN Developer lists two flags with one name
      1. WHEN the catalog test runs
         1. THEN it names that name once
2. Names a legacy key clash
   1. GIVEN Developer gives a flag a legacy key that is another flag's key
      1. WHEN the catalog test runs
         1. THEN it names both flags and the key
3. Names a variable clash
   1. GIVEN Developer lists two names that spell one environment variable
      1. WHEN the catalog test runs
         1. THEN it names both flags and the variable
4. Names a missing parent
   1. GIVEN Developer lists a child and leaves out its parent
      1. WHEN the catalog test runs
         1. THEN it names the child and the parent
5. Passes a clean catalog
   1. GIVEN Developer lists flags that share nothing
      1. WHEN the catalog test runs
         1. THEN it names none
