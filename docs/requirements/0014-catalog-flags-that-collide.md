# 0014 Flags that collide

## Why

One test names every pair of flags that would share a toggle, an override or a missing parent, before a user meets it.

## Measurement

kinds of collision the catalog names

-

kinds of collision a catalog can hold

## Requirements

- 0014.1
  - Given Developer lists two flags with one name
    - When the catalog test runs
      - Then it names that name once
- 0014.2
  - Given Developer gives a flag a legacy key that is another flag's key
    - When the catalog test runs
      - Then it names both flags and the key
- 0014.3
  - Given Developer lists two names that spell one environment variable
    - When the catalog test runs
      - Then it names both flags and the variable
- 0014.4
  - Given Developer lists a child and leaves out its parent
    - When the catalog test runs
      - Then it names the child and the parent
- 0014.5
  - Given Developer lists flags that share nothing
    - When the catalog test runs
      - Then it names none
