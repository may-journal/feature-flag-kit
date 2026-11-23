### 2026.11.23.1445

> A catalog names the flags that collide, so one app test fails before two flags share a toggle.

- Feat: `FlagCatalog.problems()` returns each `FlagCatalogProblem`: a shared name, settings key or environment variable, and a child whose parent is not listed.
- Feat: each problem describes itself in words that name the flags, for a test's failure message.
- Docs: the README's Test section adds the one-line catalog test.
