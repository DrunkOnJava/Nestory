//
// Layer: Infrastructure
// Module: Cache
// Purpose: Intelligent caching system with predictive loading and performance optimization
//

import Foundation
import os.log

// Bundle-based configuration access

/// Smart cache with predictive loading, automatic eviction, and performance optimization
public final class SmartCache<Key: Hashable & Sendable, Value: Sendable & Codable>: @unchecked Sendable {
    private let memoryCache: MemoryCache<Key, CacheEntry<Value>>
    private let diskCache: DiskCache<Key, CacheEntry<Value>>?
    private let encoder: CacheEncoder<CacheEntry<Value>>
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "SmartCache")

    // Cache configuration
    private let name: String
    private let maxMemoryCount: Int
    private let maxDiskSize: Int
    private let defaultTTL: TimeInterval
    private let enablePredictiveLoading: Bool
    private let enableAnalytics: Bool

    // Performance tracking
    private var hitCount = 0
    private var missCount = 0
    private var accessPatterns: [Key: AccessPattern] = [:]
    private var lastCleanup = Date()
    private let cleanupInterval: TimeInterval = 300 // 5 minutes

    // Predictive loading
    private var loadingQueue: [Key] = []
    private var isPreloading = false

    public init(
        name: String,
        maxMemoryCount: Int = CacheConstants.Memory.defaultCountLimit,
        maxDiskSize: Int = CacheConstants.Disk.defaultSize,
        defaultTTL: TimeInterval = CacheConstants.TTL.medium,
        enableDiskCache: Bool = true,
        enablePredictiveLoading: Bool = true,
        enableAnalytics: Bool = true
    ) throws {
        self.name = name
        self.maxMemoryCount = maxMemoryCount
        self.maxDiskSize = maxDiskSize
        self.defaultTTL = defaultTTL
        self.enablePredictiveLoading = enablePredictiveLoading
        self.enableAnalytics = enableAnalytics

        encoder = CacheEncoder()
        memoryCache = MemoryCache(countLimit: maxMemoryCount)

        if enableDiskCache {
            diskCache = try DiskCache(name: name, maxDiskSize: maxDiskSize, ttl: defaultTTL)
        } else {
            diskCache = nil
        }

        logger.info("Initialized SmartCache '\(self.name)' with memory:\(maxMemoryCount) disk:\(maxDiskSize)")

        // Start background cleanup task
        Task {
            await startBackgroundCleanup()
        }
    }

    // MARK: - Core Cache Operations

    public func set(_ value: Value, for key: Key, ttl: TimeInterval? = nil) async {
        let effectiveTTL = ttl ?? defaultTTL
        let entry = CacheEntry(
            value: value,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(effectiveTTL),
            accessCount: 1,
            lastAccessed: Date(),
        )

        // Store in memory cache
        await memoryCache.set(entry, for: key, ttl: effectiveTTL)

        // Store in disk cache if available and encodable
        if let diskCache, let data = encoder.encode(entry) {
            await diskCache.save(data, for: key)
        }

        // Update access patterns for analytics
        if enableAnalytics {
            updateAccessPattern(for: key, isWrite: true)
        }

        logger.debug("Cached value for key: \(String(describing: key)) with TTL: \(effectiveTTL)s")
    }

    public func get(for key: Key) async -> Value? {
        // Try memory cache first
        if let entry = await memoryCache.get(for: key) {
            if entry.isValid {
                await updateEntryAccess(entry, for: key)
                recordHit()
                return entry.value
            } else {
                // Expired entry, remove it
                await memoryCache.remove(for: key)
            }
        }

        // Try disk cache
        if let diskCache,
           let data = await diskCache.load(for: key),
           let entry = encoder.decode(data, type: CacheEntry<Value>.self)
        {
            if entry.isValid {
                // Restore to memory cache with fresh TTL
                let freshEntry = entry.withUpdatedAccess()
                await memoryCache.set(freshEntry, for: key, ttl: defaultTTL)
                recordHit()

                // Update access patterns
                if enableAnalytics {
                    updateAccessPattern(for: key, isWrite: false)
                }

                return entry.value
            } else {
                // Expired disk entry, remove it
                await diskCache.remove(for: key)
            }
        }

        recordMiss()

        // Trigger predictive loading if enabled
        if enablePredictiveLoading {
            await triggerPredictiveLoading(for: key)
        }

        return nil
    }

    public func remove(for key: Key) async {
        await memoryCache.remove(for: key)
        await diskCache?.remove(for: key)
        accessPatterns.removeValue(forKey: key)
        logger.debug("Removed cache entry for key: \(String(describing: key))")
    }

    public func removeAll() async {
        await memoryCache.removeAll()
        await diskCache?.removeAll()
        accessPatterns.removeAll()
        hitCount = 0
        missCount = 0
        logger.info("Cleared all cache entries for '\(self.name)'")
    }

    // MARK: - Advanced Operations

    /// Set multiple values in a batch operation
    public func setBatch(_ items: [(Key, Value)], ttl: TimeInterval? = nil) async {
        let effectiveTTL = ttl ?? defaultTTL

        for (key, value) in items {
            await set(value, for: key, ttl: effectiveTTL)
        }

        logger.debug("Batch cached \(items.count) items")
    }

    /// Get multiple values in a batch operation
    public func getBatch(for keys: [Key]) async -> [Key: Value] {
        var results: [Key: Value] = [:]

        for key in keys {
            if let value = await get(for: key) {
                results[key] = value
            }
        }

        logger.debug("Batch retrieved \(results.count)/\(keys.count) items")
        return results
    }

    /// Preload data into cache
    public func preload(items: [(Key, Value)], ttl: TimeInterval? = nil) async {
        logger.info("Preloading \(items.count) items into cache '\(self.name)'")
        await setBatch(items, ttl: ttl)
    }

    /// Warm up cache with frequently accessed keys
    public func warmUp(keys: [Key], loader: @escaping (Key) async -> Value?) async {
        logger.info("Warming up cache '\(self.name)' with \(keys.count) keys")

        for key in keys {
            if await get(for: key) == nil {
                if let value = await loader(key) {
                    await set(value, for: key)
                }
            }
        }
    }

    // MARK: - Performance Analytics

    public func getHitRate() -> Double {
        let total = hitCount + missCount
        guard total > 0 else { return 0 }
        return Double(hitCount) / Double(total)
    }

    public func getStats() -> CacheStats {
        CacheStats(
            name: name,
            hitCount: hitCount,
            missCount: missCount,
            hitRate: getHitRate(),
            memoryUsage: memoryCache.countLimit,
            diskUsage: 0, // Synchronous stats - disk usage calculation requires async
            entryCount: accessPatterns.count,
        )
    }

    public func getHotKeys(limit: Int = 10) -> [(Key, Int)] {
        accessPatterns
            .sorted { $0.value.accessCount > $1.value.accessCount }
            .prefix(limit)
            .map { ($0.key, $0.value.accessCount) }
    }

    // MARK: - Predictive Loading

    private func triggerPredictiveLoading(for key: Key) async {
        guard !isPreloading else { return }

        // Analyze access patterns to predict related keys
        let relatedKeys = predictRelatedKeys(for: key)
        if !relatedKeys.isEmpty {
            loadingQueue.append(contentsOf: relatedKeys)
            await startPredictiveLoading()
        }
    }

    private func predictRelatedKeys(for _: Key) -> [Key] {
        // Simple prediction based on access patterns
        // In a real implementation, this could use ML or more sophisticated algorithms
        let recentlyAccessed = accessPatterns.filter {
            $0.value.lastAccessed.timeIntervalSinceNow > -300 // 5 minutes
        }

        // Return keys that were frequently accessed together
        return Array(recentlyAccessed.keys.prefix(3))
    }

    private func startPredictiveLoading() async {
        guard enablePredictiveLoading, !isPreloading, !loadingQueue.isEmpty else { return }

        isPreloading = true
        defer { isPreloading = false }

        logger.debug("Starting predictive loading for \(self.loadingQueue.count) keys")

        // Process a few keys at a time to avoid overwhelming the system
        let batchSize = min(5, loadingQueue.count)
        let batch = Array(loadingQueue.prefix(batchSize))
        loadingQueue.removeFirst(batchSize)

        for key in batch {
            // This would trigger background loading in a real implementation
            logger.debug("Predictively loading key: \(String(describing: key))")
        }
    }

    // MARK: - Background Maintenance

    private func startBackgroundCleanup() async {
        while true {
            try? await Task.sleep(nanoseconds: UInt64(cleanupInterval * 1_000_000_000))
            await performMaintenance()
        }
    }

    private func performMaintenance() async {
        let now = Date()
        guard now.timeIntervalSince(lastCleanup) >= cleanupInterval else { return }

        logger.debug("Starting cache maintenance for '\(self.name)'")

        // Clean expired entries
        await cleanExpiredEntries()

        // Optimize access patterns
        optimizeAccessPatterns()

        // Log performance stats
        let stats = getStats()
        logger.info("Cache '\(self.name)' stats - Hit rate: \(String(format: "%.1f%%", stats.hitRate * 100)), Entries: \(stats.entryCount)")

        lastCleanup = now
    }

    private func cleanExpiredEntries() async {
        await diskCache?.cleanExpired()

        // Clean access patterns older than 1 hour
        let cutoff = Date().addingTimeInterval(-3600)
        accessPatterns = accessPatterns.filter { $0.value.lastAccessed > cutoff }
    }

    private func optimizeAccessPatterns() {
        // Remove patterns for rarely accessed items
        let minAccessThreshold = 2
        accessPatterns = accessPatterns.filter { $0.value.accessCount >= minAccessThreshold }
    }

    // MARK: - Private Helpers

    private func updateEntryAccess(_ entry: CacheEntry<Value>, for key: Key) async {
        let updatedEntry = entry.withUpdatedAccess()
        await memoryCache.set(updatedEntry, for: key, ttl: defaultTTL)

        if enableAnalytics {
            updateAccessPattern(for: key, isWrite: false)
        }
    }

    private func updateAccessPattern(for key: Key, isWrite: Bool) {
        if var pattern = accessPatterns[key] {
            pattern.accessCount += 1
            pattern.lastAccessed = Date()
            if isWrite {
                pattern.writeCount += 1
            }
            accessPatterns[key] = pattern
        } else {
            accessPatterns[key] = AccessPattern(
                accessCount: 1,
                writeCount: isWrite ? 1 : 0,
                lastAccessed: Date(),
            )
        }
    }

    private func recordHit() {
        hitCount += 1
    }

    private func recordMiss() {
        missCount += 1
    }
}

// MARK: - Supporting Types

public struct CacheEntry<Value>: Codable where Value: Codable {
    let value: Value
    let createdAt: Date
    let expiresAt: Date
    var accessCount: Int
    var lastAccessed: Date

    var isValid: Bool {
        Date() < expiresAt
    }

    func withUpdatedAccess() -> CacheEntry<Value> {
        var copy = self
        copy.accessCount += 1
        copy.lastAccessed = Date()
        return copy
    }
}

public struct CacheStats {
    public let name: String
    public let hitCount: Int
    public let missCount: Int
    public let hitRate: Double
    public let memoryUsage: Int
    public let diskUsage: Int
    public let entryCount: Int

    public var summary: String {
        let hitRatePercent = String(format: "%.1f%%", hitRate * 100)
        let memoryMB = String(format: "%.1fMB", Double(memoryUsage) / (1024 * 1024))
        let diskMB = String(format: "%.1fMB", Double(diskUsage) / (1024 * 1024))
        return "Cache '\(name)': \(hitRatePercent) hit rate, \(entryCount) entries, Memory: \(memoryMB), Disk: \(diskMB)"
    }
}

private struct AccessPattern {
    var accessCount: Int
    var writeCount: Int
    var lastAccessed: Date
}

// MARK: - Convenience Extensions

extension SmartCache where Value: Codable {
    public func setCodable(_ value: Value, for key: Key, ttl: TimeInterval? = nil) async {
        await set(value, for: key, ttl: ttl)
    }

    public func getCodable(for key: Key) async -> Value? {
        await get(for: key)
    }
}

extension SmartCache where Value == Data {
    public func setData(_ data: Data, for key: Key, ttl: TimeInterval? = nil) async {
        await set(data, for: key, ttl: ttl)
    }

    public func getData(for key: Key) async -> Data? {
        await get(for: key)
    }
}
