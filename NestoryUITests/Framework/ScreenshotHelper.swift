//
// ScreenshotHelper.swift
// NestoryUITests
//
// Advanced screenshot capture and management utilities
//

import XCTest
import CryptoKit

/// Helper for advanced screenshot operations
struct ScreenshotHelper {
    
    // MARK: - Configuration
    
    struct Config {
        static let outputDirectory = "/tmp/nestory_screenshots"
        static let duplicateThreshold: Double = 0.99 // 99% similarity
    }
    
    // MARK: - Screenshot Capture
    
    /// Capture and save screenshot to file system
    static func captureAndSave(app: XCUIApplication,
                               name: String,
                               subfolder: String? = nil) -> URL? {
        // Create output directory
        let outputURL = URL(fileURLWithPath: Config.outputDirectory)
            .appendingPathComponent(subfolder ?? "")
        
        try? FileManager.default.createDirectory(at: outputURL,
                                                withIntermediateDirectories: true)
        
        // Capture screenshot
        let screenshot = app.screenshot()
        let imageData = screenshot.pngRepresentation
        
        // Generate filename
        let filename = "\(name)_\(Int(Date().timeIntervalSince1970)).png"
        let fileURL = outputURL.appendingPathComponent(filename)
        
        // Write to disk
        do {
            try imageData.write(to: fileURL)
            print("📸 Screenshot saved: \(fileURL.path)")
            return fileURL
        } catch {
            print("❌ Failed to save screenshot: \(error)")
            return nil
        }
    }
    
    /// Batch capture multiple screenshots
    static func batchCapture(app: XCUIApplication,
                            views: [(name: String, setup: () -> Void)]) -> [URL] {
        var urls: [URL] = []
        
        for view in views {
            view.setup()
            
            // Wait for animations
            Thread.sleep(forTimeInterval: 0.5)
            
            if let url = captureAndSave(app: app, name: view.name) {
                urls.append(url)
            }
        }
        
        return urls
    }
    
    // MARK: - Duplicate Detection
    
    /// Calculate SHA256 hash of image data
    static func hashImage(at url: URL) -> String? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Find duplicate screenshots in directory
    static func findDuplicates(in directory: URL) -> [[URL]] {
        let fileManager = FileManager.default
        
        guard let files = try? fileManager.contentsOfDirectory(at: directory,
                                                              includingPropertiesForKeys: nil)
            .filter({ $0.pathExtension == "png" }) else {
            return []
        }
        
        // Group by hash
        var hashGroups: [String: [URL]] = [:]
        
        for file in files {
            if let hash = hashImage(at: file) {
                hashGroups[hash, default: []].append(file)
            }
        }
        
        // Return groups with duplicates
        return hashGroups.values.filter { $0.count > 1 }
    }
    
    /// Remove duplicate screenshots, keeping first of each
    static func removeDuplicates(in directory: URL) -> Int {
        let duplicateGroups = findDuplicates(in: directory)
        var removedCount = 0
        
        for group in duplicateGroups {
            // Keep first, remove rest
            for url in group.dropFirst() {
                try? FileManager.default.removeItem(at: url)
                removedCount += 1
                print("🗑 Removed duplicate: \(url.lastPathComponent)")
            }
        }
        
        return removedCount
    }
    
    // MARK: - Screenshot Comparison
    
    /// Compare two screenshots for visual differences
    static func compareScreenshots(baseline: URL, current: URL) -> Bool {
        guard let baselineHash = hashImage(at: baseline),
              let currentHash = hashImage(at: current) else {
            return false
        }
        
        return baselineHash == currentHash
    }
    
    /// Generate diff report between screenshot sets
    static func generateDiffReport(baseline: URL, current: URL) -> String {
        let baselineFiles = (try? FileManager.default
            .contentsOfDirectory(at: baseline, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "png" }) ?? []
        
        let currentFiles = (try? FileManager.default
            .contentsOfDirectory(at: current, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "png" }) ?? []
        
        var report = "Screenshot Comparison Report\n"
        report += "===========================\n"
        report += "Baseline: \(baselineFiles.count) screenshots\n"
        report += "Current: \(currentFiles.count) screenshots\n\n"
        
        // Check for matches
        for baselineFile in baselineFiles {
            let name = baselineFile.lastPathComponent
            if let currentFile = currentFiles.first(where: { $0.lastPathComponent == name }) {
                let match = compareScreenshots(baseline: baselineFile, current: currentFile)
                report += "[\(match ? "✓" : "✗")] \(name)\n"
            } else {
                report += "[−] \(name) (missing in current)\n"
            }
        }
        
        // Check for new files
        for currentFile in currentFiles {
            let name = currentFile.lastPathComponent
            if !baselineFiles.contains(where: { $0.lastPathComponent == name }) {
                report += "[+] \(name) (new in current)\n"
            }
        }
        
        return report
    }
    
    // MARK: - Cleanup
    
    /// Clean old screenshots older than specified days
    static func cleanOldScreenshots(olderThan days: Int = 7) {
        let directory = URL(fileURLWithPath: Config.outputDirectory)
        let fileManager = FileManager.default
        let cutoffDate = Date().addingTimeInterval(-Double(days * 24 * 60 * 60))
        
        guard let files = try? fileManager.contentsOfDirectory(at: directory,
                                                              includingPropertiesForKeys: [.creationDateKey]) else {
            return
        }
        
        for file in files where file.pathExtension == "png" {
            if let attributes = try? file.resourceValues(forKeys: [.creationDateKey]),
               let creationDate = attributes.creationDate,
               creationDate < cutoffDate {
                try? fileManager.removeItem(at: file)
                print("🗑 Cleaned old screenshot: \(file.lastPathComponent)")
            }
        }
    }
}