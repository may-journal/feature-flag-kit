# feature-flag-kit

A Swift package, modules `FeatureFlagKit`, `FeatureFlagKitUI` and `FeatureFlagKitTesting`, that gives an app typed feature flags with user toggles and launch overrides. See [README.md](README.md) for the pitch and [Platforms](docs/architecture/04-code.md#platforms) for versions.

## Rules

Keep plans in GitHub issues and comments. Never commit plan documents, screenshots, or review artifacts.

- Work from a plan. Non-trivial work follows a `Plan`-labeled [GitHub Issue](https://github.com/may-journal/feature-flag-kit/issues?q=label%3APlan).
- Ground changes in the design. Read the [architecture docs](docs/architecture/) first.
- Keep the docs current. Add a changelog entry for each change.
- Never name an app in this public package. The `flagWords` in [cspell.json](cspell.json) make fitness fail any file that does.
- The core target imports neither SwiftUI nor XCTest, so an app can ship it. Only `FeatureFlagKitTesting` imports XCTest.
- Run `make requirements` before a push; it runs every requirement test.
