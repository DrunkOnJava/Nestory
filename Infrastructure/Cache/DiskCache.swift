//
// Layer: Infrastructure
// Module: Cache
// Purpose: Disk-based cache for persistent storage
//

import Foundation
import os.log

public final class DiskCache<Key: Hashable & Sendable, Value>: @unchecked Sendable {
    private let fileManager = FileManager.default
    private let diskCacheURL: URL
    private let queue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev").diskCache", attributes: .concurrent)
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "DiskCache")
    private let encoder: CacheEncoder<Value>

    private let maxDiskSize: Int
    private let ttl: TimeInterval

    public init(
        name: String,
        maxDiskSize: Int = 100_000_000,
        ttl: TimeInterval = 86400
    ) throws {
        self.maxDiskSize = maxDiskSize
        self.ttl = ttl
        encoder = CacheEncoder()

        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cacheDirectory.appendingPathComponent("\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev").cache.\(name)")

        if !fileManager.fileExists(atPath: diskCacheURL.path) {
            try fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        }
    }

    // MARK: - Public Methods

    public func save(_ data: Data, for key: Key) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) { [weak self] in
                guard let self else {
                    continuation.resume()
                    return
                }

                let url = fileURL(for: key)
                do {
                    try data.write(to: url, options: .atomic)
                    logger.debug("Saved to disk cache: \(String(describing: key))")
                } catch {
                    logger.error("Failed to save to disk: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }

        await enforceDiskSizeLimit()
    }

    public func load(for key: Key) async -> Data? {
        await withCheckedContinuation { (continuation: CheckedContinuation<Data?, Never>) in
            queue.async { [weak self] in
                guard let self else {
                    continuation.resume(returning: nil)
                    return
                }

                let url = fileURL(for: key)

                guard fileManager.fileExists(atPath: url.path) else {
                    continuation.resume(returning: nil)
                    return
                }

                do {
                    let attributes = try fileManager.attributesOfItem(atPath: url.path)
                    if let modificationDate = attributes[.modificationDate] as? Date {
                        if Date().timeIntervalSince(modificationDate) > ttl {
                            try fileManager.removeItem(at: url)
                            continuation.resume(returning: nil)
                            return
                        }
                    }

                    let data = try Data(contentsOf: url)
                    logger.debug("Loaded from disk cache: \(String(describing: key))")
                    continuation.resume(returning: data)
                } catch {
                    logger.error("Failed to load from disk: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    public func remove(for key: Key) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) { [weak self] in
                guard let self else {
                    continuation.resume()
                    return
                }

                let url = fileURL(for: key)
                do {
                    if fileManager.fileExists(atPath: url.path) {
                        try fileManager.removeItem(at: url)
                        logger.debug("Removed from disk cache: \(String(describing: key))")
                    }
                } catch {
                    logger.error("Failed to remove from disk: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }
    }

    public func removeAll() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) { [weak self] in
                guard let self else {
                    continuation.resume()
                    return
                }

                do {
                    let contents = try fileManager.contentsOfDirectory(
                        at: diskCacheURL,
                        includingPropertiesForKeys: nil,
                    )
                    for url in contents {
                        try fileManager.removeItem(at: url)
                    }
                    logger.debug("Cleared disk cache")
                } catch {
                    logger.error("Failed to clear disk cache: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }
    }

    public func cleanExpired() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) { [weak self] in
                guard let self else {
                    continuation.resume()
                    return
                }

                do {
                    let contents = try fileManager.contentsOfDirectory(
                        at: diskCacheURL,
                        includingPropertiesForKeys: [.contentModificationDateKey],
                        options: [.skipsHiddenFiles],
                    )

                    let now = Date()
                    for url in contents {
                        if let attributes = try? fileManager.attributesOfItem(atPath: url.path),
                           let modificationDate = attributes[.modificationDate] as? Date
                        {
                            if now.timeIntervalSince(modificationDate) > ttl {
                                try fileManager.removeItem(at: url)
                            }
                        }
                    }

                    logger.debug("Cleaned expired disk cache entries")
                } catch {
                    logger.error("Failed to clean expired cache: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }
    }

    // MARK: - Size Management

    public func calculateUsage() async -> Int {
        await CacheSizeManager.calculateDiskUsage(at: diskCacheURL, using: fileManager)
    }

    private func enforceDiskSizeLimit() async {
        let currentSize = await calculateUsage()
        guard currentSize > maxDiskSize else { return }

        await CacheSizeManager.enforceSizeLimit(
            at: diskCacheURL,
            currentSize: currentSize,
            maxSize: maxDiskSize,
            using: fileManager,
        )
    }

    // MARK: - Private Methods

    private func fileURL(for key: Key) -> URL {
        let filename = "\(key.hashValue)"
        return diskCacheURL.appendingPathComponent(filename)
    }
}
