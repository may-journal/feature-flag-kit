import Testing

/// Runs every screen test one at a time, since rendering a screen closes the one before.
@MainActor
@Suite(.serialized) struct FeatureFlagKitTests {}
