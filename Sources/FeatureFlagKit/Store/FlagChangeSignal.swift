import Foundation

/// Tells every listener the name of each flag a store's toggle changed.
/// Unchecked because the lock guards `listeners`.
final class FlagChangeSignal: @unchecked Sendable {
    private let lock = NSLock()
    private var listeners: [UUID: AsyncStream<String>.Continuation] = [:]

    func stream() -> AsyncStream<String> {
        let (stream, continuation) = AsyncStream<String>.makeStream()
        let id = UUID()
        lock.withLock { listeners[id] = continuation }
        continuation.onTermination = { [weak self] _ in
            self?.lock.withLock { _ = self?.listeners.removeValue(forKey: id) }
        }
        return stream
    }

    func send(_ name: String) {
        for listener in lock.withLock({ Array(listeners.values) }) {
            listener.yield(name)
        }
    }
}
