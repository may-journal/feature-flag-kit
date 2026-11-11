import Foundation

/// A change callback that keeps its store's change signal alive, and stops once it is freed.
package final class FlagObservation: Sendable {
    private let signal: FlagChangeSignal
    private let id: UUID

    init(signal: FlagChangeSignal, id: UUID) {
        self.signal = signal
        self.id = id
    }

    deinit {
        signal.remove(id)
    }
}
