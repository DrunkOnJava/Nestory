//
// Layer: Infrastructure
// Module: Cache
// Purpose: In-memory cache wrapper around NSCache
//

import Foundation
import os.log

public final class MemoryCache<Key: Hashable & Sendable, Value>: @unchecked Sendable {
    private let cache = NSCache<WrappedKey, Entry>()
    private let queue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev").memoryCache", attributes: .concurrent)
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "MemoryCache")

    public init(countLimit: Int = CacheConstants.Memory.defaultCountLimit) {
        cache.countLimit = countLimit
    }

    public func set(_ value: Value, for key: Key, ttl: TimeInterval) async {
        let entry = Entry(value: value, expirationDate: Date().addingTimeInterval(ttl))
        let wrappedKey = WrappedKey(key)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) { [weak self] in
                self?.cache.setObject(entry, forKey: wrappedKey)
                continuation.resume()
            }
        }
    }

    public func get(for key: Key) async -> Value? {
        let wrappedKey = WrappedKey(key)

        let entry = await withCheckedContinuation { (continuation: CheckedContinuation<Entry?, Never>) in
            queue.async { [weak self] in
                continuation.resume(returning: self?.cache.object(forKey: wrappedKey))
            }
        }

        guard let entry else { return nil }

        if entry.expirationDate > Date() {
            return entry.value as? Value
        } else {
            await remove(for: key)
            return nil
        }
    }

    public func remove(for key: Key) async {
        let wrappedKey = WrappedKey(key)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) { [weak self] in
                self?.cache.removeObject(forKey: wrappedKey)
                continuation.resume()
            }
        }
    }

    public func removeAll() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) { [weak self] in
                self?.cache.removeAllObjects()
                continuation.resume()
            }
        }
    }

    public var countLimit: Int {
        cache.countLimit
    }
}

// MARK: - Supporting Types

private final class WrappedKey: NSObject, @unchecked Sendable {
    let key: AnyHashable

    init(_ key: some Hashable) {
        self.key = AnyHashable(key)
        super.init()
    }

    override var hash: Int {
        key.hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? WrappedKey else { return false }
        return key == other.key
    }
}

private final class Entry: @unchecked Sendable {
    let value: Any
    let expirationDate: Date

    init(value: Any, expirationDate: Date) {
        self.value = value
        self.expirationDate = expirationDate
    }
}
