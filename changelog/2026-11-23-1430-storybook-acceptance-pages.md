### 2026.11.23.1430

> Every requirement acceptance has a Storybook page named by its ID.

- Fix: the debug screen's 14 pages start with the acceptance they show, such as "0006.1 Debug screen: number edited".
- Feat: each other acceptance has its own page, built from `@FlagState`, `FlagDebugView` and the store on isolated settings.
- Docs: the README's Storybook section names the pages and where they live.
