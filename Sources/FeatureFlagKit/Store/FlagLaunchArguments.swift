/// A flag that can spell its own value as launch arguments, whatever type it holds.
protocol LaunchSpelledFlag: AnyFlag {
    /// The arguments that force the flag to the value its own layers give in `store`, or
    /// none when that is its compiled default.
    func launchArguments(in store: FlagStore) -> [String]
}

extension Flag: LaunchSpelledFlag {
    func launchArguments(in store: FlagStore) -> [String] {
        let value = store.ownResolution(self).value
        return value == defaultValue ? [] : FlagEncoding.arguments(self, value)
    }
}

extension FlagStore {
    /// The launch arguments that start another launch with this store's flags.
    /// It spells each flag this build ships whose own layers differ from its compiled default.
    public func launchArguments(for catalog: FlagCatalog) -> [String] {
        catalog.filter { isAvailable($0) }.flatMap { flag in
            (flag as? any LaunchSpelledFlag)?.launchArguments(in: self) ?? []
        }
    }
}
