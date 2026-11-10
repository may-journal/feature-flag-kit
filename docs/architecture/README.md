# Architecture

Design for feature-flag-kit. Each acceptance in [docs/requirements](../requirements/) has its test.

## Principles

1. Each app keeps its own flag list; the kit supplies only the machinery.
1. Precedence is launch argument, environment, the user's toggle, then the compiled default.
1. The core target has no UI and no XCTest, so an app ships it. SwiftUI lives only in `FeatureFlagKitUI`.

## C4 docs

- [01-system-context.md](01-system-context.md): who meets the kit.
- [02-containers.md](02-containers.md): the library and its test bundle.
- [03-components.md](03-components.md): the library's folders.
- [04-code.md](04-code.md): the core's and the SwiftUI target's types, platforms and tests.
- [05-user-journey.md](05-user-journey.md): from defining a flag to seeing the feature or the debug screen.
