// Layer: Infrastructure

import Foundation
import os.log
import UIKit

public final class Cache<Key: Hashable & Sendable, Value>: @unchecked Sendable {
    private let memoryCache = NSCache<WrappedKey, Entry>()
    private let fileManager = FileManager.default
    private let diskCacheURL: URL
    private let queue = DispatchQueue(label: "com.nestory.cache", attributes: .concurrent)
    private let logger = Logger(subsystem: "com.nestory", category: "Cache")

    private let maxMemoryCount: Int
    private let maxDiskSize: Int
    private let ttl: TimeInterval

    public init(
        name: String,
        maxMemoryCount: Int = 100,
        maxDiskSize: Int = 100_000_000,
        ttl: TimeInterval = 86400
    ) throws {
        self.maxMemoryCount = maxMemoryCount
        self.maxDiskSize = maxDiskSize
        self.ttl = ttl

        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cacheDirectory.appendingPathComponent("com.nestory.cache.\(name)")

        if !fileManager.fileExists(atPath: diskCacheURL.path) {
            try fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        }

        memoryCache.countLimit = maxMemoryCount

        Task {
            await cleanExpiredDiskCache()
        }
    }

    public func set(_ value: Value, for key: Key) async {
        let entry = Entry(value: value, expirationDate: Date().addingTimeInterval(ttl))
        let wrappedKey = WrappedKey(key)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) { [weak self] in
                self?.memoryCache.setObject(entry, forKey: wrappedKey)
                continuation.resume()
            }
        }

        if let data = encode(value) {
            await saveToDisk(data, for: key)
        }
    }

    public func get(for key: Key) async -> Value? {
        let wrappedKey = WrappedKey(key)

        if let entry = await withCheckedContinuation({ (continuation: CheckedContinuation<Entry?, Never>) in
            queue.async { [weak self] in
                continuation.resume(returning: self?.memoryCache.object(forKey: wrappedKey))
            }
        }) {
            if entry.expirationDate > Date() {
                if let value = entry.value as? Value {
                    return value
                }
            } else {
                await remove(for: key)
                return nil
            }
        }

        if let value = await loadFromDisk(for: key) {
            await set(value, for: key)
            return value
        }

        return nil
    }

    public func remove(for key: Key) async {
        let wrappedKey = WrappedKey(key)

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) { [weak self] in
                self?.memoryCache.removeObject(forKey: wrappedKey)
                continuation.resume()
            }
        }

        await removeFromDisk(for: key)
    }

    public func removeAll() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) { [weak self] in
                self?.memoryCache.removeAllObjects()
                continuation.resume()
            }
        }

        await removeAllFromDisk()
    }

    public func contains(key: Key) async -> Bool {
        await get(for: key) != nil
    }

    public func memoryUsage() -> Int {
        memoryCache.countLimit
    }

    public func diskUsage() async -> Int {
        await withCheckedContinuation { (continuation: CheckedContinuation<Int, Never>) in
            queue.async { [weak self] in
                guard let self else {
                    continuation.resume(returning: 0)
                    return
                }

                do {
                    let contents = try fileManager.contentsOfDirectory(
                        at: diskCacheURL,
                        includingPropertiesForKeys: [.fileSizeKey],
                        options: [.skipsHiddenFiles]
                    )

                    let totalSize = contents.reduce(0) { sum, url in
                        let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                        return sum + size
                    }

                    continuation.resume(returning: totalSize)
                } catch {
                    logger.error("Failed to calculate disk usage: \(error.localizedDescription)")
                    continuation.resume(returning: 0)
                }
            }
        }
    }

    private func saveToDisk(_ data: Data, for key: Key) async {
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

    private func loadFromDisk(for key: Key) async -> Value? {
        await withCheckedContinuation { (continuation: CheckedContinuation<Value?, Never>) in
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
                    let value = decode(data, type: Value.self)
                    logger.debug("Loaded from disk cache: \(String(describing: key))")
                    continuation.resume(returning: value)
                } catch {
                    logger.error("Failed to load from disk: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private func removeFromDisk(for key: Key) async {
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

    private func removeAllFromDisk() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) { [weak self] in
                guard let self else {
                    continuation.resume()
                    return
                }

                do {
                    let contents = try fileManager.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: nil)
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

    private func cleanExpiredDiskCache() async {
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
                        options: [.skipsHiddenFiles]
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

    private func enforceDiskSizeLimit() async {
        let currentSize = await diskUsage()

        guard currentSize > maxDiskSize else { return }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async(flags: .barrier) { [weak self] in
                guard let self else {
                    continuation.resume()
                    return
                }

                do {
                    let contents = try fileManager.contentsOfDirectory(
                        at: diskCacheURL,
                        includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
                        options: [.skipsHiddenFiles]
                    )

                    let sortedContents = contents.sorted { url1, url2 in
                        let date1 = (try? url1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                        let date2 = (try? url2.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                        return date1 < date2
                    }

                    var totalSize = currentSize
                    for url in sortedContents {
                        guard totalSize > maxDiskSize else { break }

                        let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                        try fileManager.removeItem(at: url)
                        totalSize -= size
                    }

                    logger.debug("Enforced disk size limit")
                } catch {
                    logger.error("Failed to enforce disk size limit: \(error.localizedDescription)")
                }
                continuation.resume()
            }
        }
    }

    private func fileURL(for key: Key) -> URL {
        let filename = "\(key.hashValue)"
        return diskCacheURL.appendingPathComponent(filename)
    }

    private func encode(_ value: Value) -> Data? {
        if let data = value as? Data {
            return data
        }

        if let codable = value as? any Codable {
            return try? JSONEncoder().encode(AnyEncodable(codable))
        }

        if let image = value as? UIImage {
            return image.jpegData(compressionQuality: 0.8)
        }

        return nil
    }

    private func decode<T>(_ data: Data, type: T.Type) -> T? {
        if type == Data.self {
            return data as? T
        }

        if let decodableType = type as? any Decodable.Type {
            return (try? JSONDecoder().decode(decodableType, from: data)) as? T
        }

        if type == UIImage.self {
            return UIImage(data: data) as? T
        }

        return nil
    }

    func cache(_: NSCache<AnyObject, AnyObject>, willEvictObject _: Any) {
        logger.debug("Memory cache will evict object")
    }
}

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

private struct AnyEncodable: Encodable {
    private let _encode: (any Encoder) throws -> Void

    init(_ wrapped: any Encodable) {
        _encode = wrapped.encode
    }

    func encode(to encoder: any Encoder) throws {
        try _encode(encoder)
    }
}
