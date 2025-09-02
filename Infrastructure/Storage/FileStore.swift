// Layer: Infrastructure

import Foundation
import os.log

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with Compression - Add Compression framework for automatic file compression and decompression

public final class FileStore: @unchecked Sendable {
    private let baseDirectory: URL
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory.dev").filestore", attributes: .concurrent)
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "FileStore")

    public enum Directory {
        case documents
        case caches
        case temporary
        case applicationSupport
        case custom(URL)

        var url: URL {
            switch self {
            case .documents:
                FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory.appendingPathComponent("Documents")
            case .caches:
                FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory.appendingPathComponent("Caches")
            case .temporary:
                FileManager.default.temporaryDirectory
            case .applicationSupport:
                FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory.appendingPathComponent("ApplicationSupport")
            case let .custom(url):
                url
            }
        }
    }

    public init(directory: Directory = .applicationSupport, subdirectory: String? = nil) throws {
        var baseURL = directory.url

        if let subdirectory {
            baseURL = baseURL.appendingPathComponent(subdirectory)
        }

        baseDirectory = baseURL

        if !fileManager.fileExists(atPath: baseURL.path) {
            try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
        }
    }

    public func save(_ object: some Encodable & Sendable, to relativePath: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                do {
                    let url = self.url(for: relativePath)
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    encoder.dateEncodingStrategy = .iso8601
                    let data = try encoder.encode(object)

                    let directory = url.deletingLastPathComponent()
                    if !self.fileManager.fileExists(atPath: directory.path) {
                        try self.fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                    }

                    try data.write(to: url, options: .atomic)
                    self.logger.debug("Saved file: \(relativePath)")
                    continuation.resume()
                } catch {
                    self.logger.error("Failed to save file: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func load<T: Decodable>(_ type: T.Type, from relativePath: String) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let url = self.url(for: relativePath)
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let object = try decoder.decode(type, from: data)
                    self.logger.debug("Loaded file: \(relativePath)")
                    continuation.resume(returning: object)
                } catch {
                    self.logger.error("Failed to load file: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func saveData(_ data: Data, to relativePath: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                do {
                    let url = self.url(for: relativePath)
                    let directory = url.deletingLastPathComponent()

                    if !self.fileManager.fileExists(atPath: directory.path) {
                        try self.fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                    }

                    try data.write(to: url, options: .atomic)
                    self.logger.debug("Saved data: \(relativePath) (\(data.count) bytes)")
                    continuation.resume()
                } catch {
                    self.logger.error("Failed to save data: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func loadData(from relativePath: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let url = self.url(for: relativePath)
                    let data = try Data(contentsOf: url)
                    self.logger.debug("Loaded data: \(relativePath) (\(data.count) bytes)")
                    continuation.resume(returning: data)
                } catch {
                    self.logger.error("Failed to load data: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func delete(_ relativePath: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async(flags: .barrier) {
                do {
                    let url = self.url(for: relativePath)
                    if self.fileManager.fileExists(atPath: url.path) {
                        try self.fileManager.removeItem(at: url)
                        self.logger.debug("Deleted file: \(relativePath)")
                    }
                    continuation.resume()
                } catch {
                    self.logger.error("Failed to delete file: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func exists(_ relativePath: String) -> Bool {
        queue.sync {
            let url = self.url(for: relativePath)
            return fileManager.fileExists(atPath: url.path)
        }
    }

    public func listFiles(in relativePath: String = "") async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let url = self.url(for: relativePath)
                    let contents = try self.fileManager.contentsOfDirectory(
                        at: url,
                        includingPropertiesForKeys: [.isRegularFileKey],
                        options: [.skipsHiddenFiles],
                    )

                    let files = contents.compactMap { fileURL -> String? in
                        let resourceValues = try? fileURL.resourceValues(forKeys: [.isRegularFileKey])
                        guard resourceValues?.isRegularFile == true else { return nil }
                        return fileURL.lastPathComponent
                    }

                    continuation.resume(returning: files)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func size(of relativePath: String) async throws -> Int64 {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let url = self.url(for: relativePath)
                    let attributes = try self.fileManager.attributesOfItem(atPath: url.path)
                    let size = attributes[.size] as? Int64 ?? 0
                    continuation.resume(returning: size)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func totalSize() async throws -> Int64 {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let size = try self.calculateDirectorySize(self.baseDirectory)
                    continuation.resume(returning: size)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func calculateDirectorySize(_ url: URL) throws -> Int64 {
        var totalSize: Int64 = 0

        let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles],
        )

        while let fileURL = enumerator?.nextObject() as? URL {
            let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
            totalSize += Int64(resourceValues.fileSize ?? 0)
        }

        return totalSize
    }

    private func url(for relativePath: String) -> URL {
        if relativePath.isEmpty {
            return baseDirectory
        }
        return baseDirectory.appendingPathComponent(relativePath)
    }
}
