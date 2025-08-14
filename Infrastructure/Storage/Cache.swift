//
// Layer: Infrastructure
// Module: Storage
// Purpose: Main cache coordinator combining memory and disk caching
//

import Foundation
import os.log

public final class Cache<Key: Hashable & Sendable, Value>: @unchecked Sendable {
    private let memoryCache: MemoryCache<Key, Value>
    private let diskCache: DiskCache<Key, Value>
    private let encoder: CacheEncoder<Value>
    private let logger = Logger(subsystem: "com.nestory", category: "Cache")

    private let ttl: TimeInterval

    // MARK: - Initialization

    public init(
        name: String,
        maxMemoryCount: Int = 100,
        maxDiskSize: Int = 100_000_000,
        ttl: TimeInterval = 86400
    ) throws {
        self.ttl = ttl
        encoder = CacheEncoder()
        memoryCache = MemoryCache(countLimit: maxMemoryCount)
        diskCache = try DiskCache(
            name: name,
            maxDiskSize: maxDiskSize,
            ttl: ttl,
        )

        Task {
            await diskCache.cleanExpired()
        }
    }

    // MARK: - Public Interface

    public func set(_ value: Value, for key: Key) async {
        // Store in memory cache
        await memoryCache.set(value, for: key, ttl: ttl)

        // Store in disk cache if encodable
        if let data = encoder.encode(value) {
            await diskCache.save(data, for: key)
        }
    }

    public func get(for key: Key) async -> Value? {
        // Try memory cache first
        if let value = await memoryCache.get(for: key) {
            return value
        }

        // Try disk cache
        if let data = await diskCache.load(for: key),
           let value = encoder.decode(data, type: Value.self)
        {
            // Restore to memory cache
            await memoryCache.set(value, for: key, ttl: ttl)
            return value
        }

        return nil
    }

    public func remove(for key: Key) async {
        await memoryCache.remove(for: key)
        await diskCache.remove(for: key)
    }

    public func removeAll() async {
        await memoryCache.removeAll()
        await diskCache.removeAll()
    }

    public func contains(key: Key) async -> Bool {
        await get(for: key) != nil
    }

    // MARK: - Usage Statistics

    public func memoryUsage() -> Int {
        memoryCache.countLimit
    }

    public func diskUsage() async -> Int {
        await diskCache.calculateUsage()
    }

    public func totalUsage() async -> (memory: Int, disk: Int) {
        let memory = memoryUsage()
        let disk = await diskUsage()
        return (memory, disk)
    }

    // MARK: - Maintenance

    public func cleanExpiredEntries() async {
        await diskCache.cleanExpired()
        logger.info("Cleaned expired cache entries")
    }

    public func preloadIntoMemory(keys: [Key]) async {
        for key in keys {
            if let data = await diskCache.load(for: key),
               let value = encoder.decode(data, type: Value.self)
            {
                await memoryCache.set(value, for: key, ttl: ttl)
            }
        }
        logger.info("Preloaded \(keys.count) items into memory cache")
    }
}

// MARK: - Convenience Extensions

public extension Cache where Value: Codable {
    func setCodable(_ value: Value, for key: Key) async {
        await set(value, for: key)
    }

    func getCodable(for key: Key) async -> Value? {
        await get(for: key)
    }
}

public extension Cache where Value == Data {
    func setData(_ data: Data, for key: Key) async {
        await set(data, for: key)
    }

    func getData(for key: Key) async -> Data? {
        await get(for: key)
    }
}
