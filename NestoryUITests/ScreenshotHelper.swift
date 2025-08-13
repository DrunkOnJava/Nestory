//
//  ScreenshotHelper.swift
//  NestoryUITests
//
//  Created by Assistant on 8/9/25.
//

import XCTest

final class ScreenshotHelper {
    static let shared = ScreenshotHelper()

    private let fileManager = FileManager.default
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()

    private init() {}

    /// Takes a screenshot and saves it with the given name
    func takeScreenshot(app: XCUIApplication, name: String, testCase: XCTestCase) {
        let screenshot = app.screenshot()

        // Attach to test results
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        testCase.add(attachment)

        // Save to file system
        saveScreenshotToFile(screenshot: screenshot, name: name)
    }

    /// Saves screenshot to the file system
    private func saveScreenshotToFile(screenshot: XCUIScreenshot, name: String) {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not find documents directory")
            return
        }

        let timestamp = dateFormatter.string(from: Date())
        let screenshotDir = documentsPath.appendingPathComponent("NestoryScreenshots/\(timestamp)")

        // Create directory if needed
        do {
            try fileManager.createDirectory(at: screenshotDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create screenshot directory: \(error)")
            return
        }

        let fileName = "\(name).png"
        let fileURL = screenshotDir.appendingPathComponent(fileName)

        do {
            try screenshot.pngRepresentation.write(to: fileURL)
            print("✅ Screenshot saved: \(fileURL.path)")
        } catch {
            print("❌ Failed to save screenshot: \(error)")
        }
    }

    /// Gets the path where screenshots are saved
    func getScreenshotDirectory() -> URL? {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let timestamp = dateFormatter.string(from: Date())
        return documentsPath.appendingPathComponent("NestoryScreenshots/\(timestamp)")
    }

    /// Cleans up old screenshots (older than 7 days)
    func cleanupOldScreenshots(daysToKeep: Int = 7) {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let screenshotDir = documentsPath.appendingPathComponent("NestoryScreenshots")

        do {
            let folders = try fileManager.contentsOfDirectory(at: screenshotDir, includingPropertiesForKeys: [.creationDateKey])
            let cutoffDate = Date().addingTimeInterval(-Double(daysToKeep * 24 * 60 * 60))

            for folder in folders {
                if let attributes = try? fileManager.attributesOfItem(atPath: folder.path),
                   let creationDate = attributes[.creationDate] as? Date,
                   creationDate < cutoffDate
                {
                    try fileManager.removeItem(at: folder)
                    print("Removed old screenshot folder: \(folder.lastPathComponent)")
                }
            }
        } catch {
            print("Error cleaning up screenshots: \(error)")
        }
    }
}

// MARK: - Test Configuration

enum TestConfiguration {
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING_MODE")
    }

    static var shouldClearData: Bool {
        ProcessInfo.processInfo.arguments.contains("CLEAR_DATA")
    }

    static var shouldTakeScreenshots: Bool {
        ProcessInfo.processInfo.environment["SCREENSHOTS"] == "YES"
    }

    static var deviceName: String {
        UIDevice.current.name
    }

    static var systemVersion: String {
        UIDevice.current.systemVersion
    }
}
