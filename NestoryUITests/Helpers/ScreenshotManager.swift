//
// ScreenshotManager.swift
// NestoryUITests
//
// Thread-safe screenshot management using Swift 6 actor isolation
// Handles screenshot capture, attachment creation, and file management
//

import Foundation
import XCTest

/// Thread-safe screenshot manager using actor isolation
@MainActor
final class ScreenshotManager {
    // MARK: - Properties

    private var screenshotCount = 0
    private let fileManager = FileManager.default
    private let timestampFormatter: DateFormatter

    /// Screenshot metadata for tracking and reporting
    struct ScreenshotMetadata: Sendable {
        let name: String
        let timestamp: Date
        let testCaseName: String
        let screenshotNumber: Int
        let filePath: URL?
    }

    private var capturedScreenshots: [ScreenshotMetadata] = []

    // MARK: - Initialization

    init() {
        timestampFormatter = DateFormatter()
        timestampFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        timestampFormatter.locale = Locale(identifier: "en_US_POSIX")
        timestampFormatter.timeZone = TimeZone.current

        print("📸 ScreenshotManager initialized")
    }

    // MARK: - Screenshot Capture

    /// Capture a screenshot from the application
    /// - Parameters:
    ///   - app: The XCUIApplication to capture
    ///   - name: Name for the screenshot
    ///   - testCase: The test case requesting the screenshot
    func captureScreenshot(
        from app: XCUIApplication,
        name: String,
        testCase: XCTestCase,
    ) async {
        do {
            // Increment counter
            screenshotCount += 1

            // Create clean name
            let cleanName = sanitizeName(name)
            let timestamp = Date()

            // Capture screenshot
            let screenshot = app.screenshot()

            // Create XCTest attachment
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = "\(screenshotCount)_\(cleanName)"
            attachment.lifetime = .keepAlways
            testCase.add(attachment)

            // Save to file system for external access
            let filePath = try await saveScreenshotToFile(
                screenshot: screenshot,
                name: cleanName,
                testCaseName: testCase.name,
            )

            // Store metadata
            let metadata = ScreenshotMetadata(
                name: cleanName,
                timestamp: timestamp,
                testCaseName: testCase.name,
                screenshotNumber: screenshotCount,
                filePath: filePath,
            )
            capturedScreenshots.append(metadata)

            print("📸 Captured screenshot \(screenshotCount): \(cleanName)")

        } catch {
            print("❌ Failed to capture screenshot '\(name)': \(error)")
            XCTFail("Screenshot capture failed: \(error.localizedDescription)")
        }
    }

    // MARK: - File Management

    /// Save screenshot to file system
    private func saveScreenshotToFile(
        screenshot: XCUIScreenshot,
        name: String,
        testCaseName: String,
    ) async throws -> URL? {
        // Get documents directory
        guard let documentsPath = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask,
        ).first else {
            throw ScreenshotError.cannotFindDocumentsDirectory
        }

        // Create timestamped directory
        let timestamp = timestampFormatter.string(from: Date())
        let screenshotDir = documentsPath
            .appendingPathComponent("NestoryUITestScreenshots")
            .appendingPathComponent(timestamp)
            .appendingPathComponent(sanitizeFileName(testCaseName))

        // Create directory structure
        try fileManager.createDirectory(
            at: screenshotDir,
            withIntermediateDirectories: true,
            attributes: nil,
        )

        // Create file path
        let fileName = "\(String(format: "%03d", screenshotCount))_\(name).png"
        let filePath = screenshotDir.appendingPathComponent(fileName)

        // Write screenshot data
        try screenshot.pngRepresentation.write(to: filePath)

        print("💾 Saved screenshot to: \(filePath.path)")
        return filePath
    }

    // MARK: - Utility Methods

    /// Sanitize name for use in file names and identifiers
    private func sanitizeName(_ name: String) -> String {
        name
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "[^a-zA-Z0-9_-]", with: "", options: .regularExpression)
            .lowercased()
    }

    /// Sanitize file name for file system
    private func sanitizeFileName(_ fileName: String) -> String {
        fileName
            .replacingOccurrences(of: "[", with: "_")
            .replacingOccurrences(of: "]", with: "_")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: " ", with: "_")
    }

    // MARK: - Reporting

    /// Get summary of captured screenshots
    func getScreenshotSummary() -> String {
        let summary = """
        📸 Screenshot Summary:
        - Total Screenshots: \(screenshotCount)
        - Test Cases: \(Set(capturedScreenshots.map(\.testCaseName)).count)
        - First Capture: \(capturedScreenshots.first?.timestamp.description ?? "None")
        - Last Capture: \(capturedScreenshots.last?.timestamp.description ?? "None")
        """
        return summary
    }

    /// Get all screenshot metadata
    func getAllScreenshots() -> [ScreenshotMetadata] {
        capturedScreenshots
    }

    /// Clear all captured screenshots metadata
    func clearHistory() {
        capturedScreenshots.removeAll()
        screenshotCount = 0
        print("🧹 Screenshot history cleared")
    }
}

// MARK: - Error Types

enum ScreenshotError: Error, LocalizedError {
    case cannotFindDocumentsDirectory
    case fileWriteError(Error)
    case invalidScreenshotData

    var errorDescription: String? {
        switch self {
        case .cannotFindDocumentsDirectory:
            "Cannot find documents directory for screenshot storage"
        case let .fileWriteError(error):
            "Failed to write screenshot file: \(error.localizedDescription)"
        case .invalidScreenshotData:
            "Invalid screenshot data received"
        }
    }
}
