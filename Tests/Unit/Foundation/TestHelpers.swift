//
// TestHelpers.swift
// NestoryTests
//
// Comprehensive test helpers and utilities for Nestory testing
//

import Foundation
@testable import Nestory
import Testing
import XCTest

// MARK: - Test Data Builders

/// Builder pattern for creating test Item instances
struct ItemBuilder {
    private var id = UUID()
    private var name = "Test Item"
    private var category = "Test Category"
    private var purchasePrice = Money(amount: 100.0, currencyCode: "USD")
    private var purchaseDate = Date()
    private var condition = "Excellent"
    private var location = "Living Room"

    func with(id: UUID) -> ItemBuilder {
        var builder = self
        builder.id = id
        return builder
    }

    func with(name: String) -> ItemBuilder {
        var builder = self
        builder.name = name
        return builder
    }

    func with(category: String) -> ItemBuilder {
        var builder = self
        builder.category = category
        return builder
    }

    func with(purchasePrice: Money) -> ItemBuilder {
        var builder = self
        builder.purchasePrice = purchasePrice
        return builder
    }

    func with(purchaseDate: Date) -> ItemBuilder {
        var builder = self
        builder.purchaseDate = purchaseDate
        return builder
    }

    func with(condition: String) -> ItemBuilder {
        var builder = self
        builder.condition = condition
        return builder
    }

    func with(location: String) -> ItemBuilder {
        var builder = self
        builder.location = location
        return builder
    }

    func build() -> Item {
        Item(
            id: id,
            name: name,
            category: category,
            purchasePrice: purchasePrice,
            purchaseDate: purchaseDate,
            condition: condition,
            location: location,
        )
    }
}

/// Builder pattern for creating test Money instances
struct MoneyBuilder {
    private var amount = 0.0
    private var currency: CurrencyCode = .USD

    func with(amount: Double) -> MoneyBuilder {
        var builder = self
        builder.amount = amount
        return builder
    }

    func with(currency: CurrencyCode) -> MoneyBuilder {
        var builder = self
        builder.currency = currency
        return builder
    }

    func build() -> Money {
        Money(amount: amount, currency: currency)
    }
}

/// Builder pattern for creating test Warranty instances
struct WarrantyBuilder {
    private var id = UUID()
    private var itemId = UUID()
    private var startDate = Date()
    private var endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    private var type = "Manufacturer"
    private var provider = "Test Provider"
    private var terms = "Standard warranty terms"

    func with(id: UUID) -> WarrantyBuilder {
        var builder = self
        builder.id = id
        return builder
    }

    func with(itemId: UUID) -> WarrantyBuilder {
        var builder = self
        builder.itemId = itemId
        return builder
    }

    func with(startDate: Date) -> WarrantyBuilder {
        var builder = self
        builder.startDate = startDate
        return builder
    }

    func with(endDate: Date) -> WarrantyBuilder {
        var builder = self
        builder.endDate = endDate
        return builder
    }

    func with(type: String) -> WarrantyBuilder {
        var builder = self
        builder.type = type
        return builder
    }

    func with(provider: String) -> WarrantyBuilder {
        var builder = self
        builder.provider = provider
        return builder
    }

    func with(terms: String) -> WarrantyBuilder {
        var builder = self
        builder.terms = terms
        return builder
    }

    func build() -> Warranty {
        Warranty(
            id: id,
            itemId: itemId,
            startDate: startDate,
            endDate: endDate,
            type: type,
            provider: provider,
            terms: terms,
        )
    }
}

// MARK: - Mock Services

/// Mock implementation of AnalyticsService for testing
class MockAnalyticsService: AnalyticsServiceProtocol {
    var trackEventCalls: [(String, [String: Any])] = []
    var trackItemAdditionCalls: [Item] = []
    var trackItemUpdateCalls: [Item] = []
    var trackItemDeletionCalls: [UUID] = []
    var shouldFail = false
    var error: Error?

    func trackEvent(_ eventName: String, parameters: [String: Any]) {
        trackEventCalls.append((eventName, parameters))
    }

    func trackItemAddition(_ item: Item) {
        trackItemAdditionCalls.append(item)
    }

    func trackItemUpdate(_ item: Item) {
        trackItemUpdateCalls.append(item)
    }

    func trackItemDeletion(_ itemId: UUID) {
        trackItemDeletionCalls.append(itemId)
    }

    func reset() {
        trackEventCalls.removeAll()
        trackItemAdditionCalls.removeAll()
        trackItemUpdateCalls.removeAll()
        trackItemDeletionCalls.removeAll()
        shouldFail = false
        error = nil
    }
}

/// Mock implementation of CloudBackupService for testing
@MainActor
class MockCloudBackupService: CloudBackupService {
    var isBackingUp: Bool = false
    var isRestoring: Bool = false
    var lastBackupDate: Date? = nil
    var backupStatus: BackupStatus = .idle
    var errorMessage: String? = nil
    var progress: Double = 0.0
    var isCloudKitAvailable: Bool = true
    
    var backupCalls: [BackupOperation] = []
    var restoreCalls: [RestoreOperation] = []
    var shouldFail = false
    var error: Error?
    
    func checkCloudKitAvailability() async -> Bool {
        return isCloudKitAvailable
    }
    
    func performBackup(items: [Item], categories: [Category], rooms: [Room]) async throws {
        let operation = BackupOperation(items: items, timestamp: Date())
        backupCalls.append(operation)
        
        if shouldFail, let error {
            throw error
        }
    }
    
    func estimateBackupSize(items: [Item]) -> String {
        return "\(items.count) items (~1.2 MB)"
    }
    
    func getBackupInfo() async throws -> BackupMetadata? {
        return BackupMetadata(id: UUID(), timestamp: Date(), itemCount: 0)
    }
    
    func performRestore(modelContext: ModelContext) async throws -> RestoreResult {
        let operation = RestoreOperation(timestamp: Date())
        restoreCalls.append(operation)

        if shouldFail, let error {
            throw error
        }

        return RestoreResult(
            itemsRestored: 0,
            categoriesRestored: 0,
            roomsRestored: 0,
            backupDate: Date()
        )
    }

    func reset() {
        backupCalls.removeAll()
        restoreCalls.removeAll()
        shouldFail = false
        error = nil
        backupResult = .success(BackupMetadata(id: UUID(), timestamp: Date(), itemCount: 0))
        restoreResult = .success([])
    }
}

// MARK: - Mock Operation Types

struct BackupOperation {
    let items: [Item]
    let timestamp: Date
}

struct RestoreOperation {
    let timestamp: Date
}

// MARK: - Test Fixtures

enum TestFixtures {
    static let sampleItems: [Item] = [
        ItemBuilder()
            .with(name: "MacBook Pro")
            .with(category: "Electronics")
            .with(purchasePrice: MoneyBuilder().with(amount: 2499.00).build())
            .build(),

        ItemBuilder()
            .with(name: "iPhone 15 Pro")
            .with(category: "Electronics")
            .with(purchasePrice: MoneyBuilder().with(amount: 1199.00).build())
            .build(),

        ItemBuilder()
            .with(name: "Leather Sofa")
            .with(category: "Furniture")
            .with(purchasePrice: MoneyBuilder().with(amount: 1500.00).build())
            .with(location: "Living Room")
            .build(),
    ]

    static let sampleWarranties: [Warranty] = [
        WarrantyBuilder()
            .with(type: "AppleCare+")
            .with(provider: "Apple Inc.")
            .with(terms: "3 years of hardware coverage")
            .build(),

        WarrantyBuilder()
            .with(type: "Extended Warranty")
            .with(provider: "Best Buy")
            .with(terms: "2 years additional coverage")
            .build(),
    ]

    static let sampleCategories: [Category] = [
        Category(id: UUID(), name: "Electronics", icon: "laptopcomputer"),
        Category(id: UUID(), name: "Furniture", icon: "sofa"),
        Category(id: UUID(), name: "Appliances", icon: "refrigerator"),
        Category(id: UUID(), name: "Jewelry", icon: "ring"),
        Category(id: UUID(), name: "Collectibles", icon: "trophy"),
    ]

    static let sampleRooms: [Room] = [
        Room(id: UUID(), name: "Living Room"),
        Room(id: UUID(), name: "Bedroom"),
        Room(id: UUID(), name: "Kitchen"),
        Room(id: UUID(), name: "Home Office"),
        Room(id: UUID(), name: "Garage"),
    ]
}

// MARK: - Custom Assertions

/// Custom assertion for comparing Money values with tolerance
func assertMoneyEqual(
    _ actual: Money,
    _ expected: Money,
    accuracy: Double = 0.01,
    _: String = "",
    sourceLocation: SourceLocation = #_sourceLocation,
) {
    #expect(
        actual.currency == expected.currency,
        "Currency mismatch: \(actual.currency) != \(expected.currency)",
        sourceLocation: sourceLocation,
    )

    #expect(
        abs(actual.amount - expected.amount) <= accuracy,
        "Amount mismatch: \(actual.amount) != \(expected.amount) (tolerance: \(accuracy))",
        sourceLocation: sourceLocation,
    )
}

/// Custom assertion for comparing dates with tolerance
func assertDateEqual(
    _ actual: Date,
    _ expected: Date,
    accuracy: TimeInterval = 1.0,
    _: String = "",
    sourceLocation: SourceLocation = #_sourceLocation,
) {
    #expect(
        abs(actual.timeIntervalSince(expected)) <= accuracy,
        "Date mismatch: \(actual) != \(expected) (tolerance: \(accuracy)s)",
        sourceLocation: sourceLocation,
    )
}

/// Custom assertion for validating UUID format
func assertValidUUID(
    _ uuid: UUID,
    _: String = "",
    sourceLocation: SourceLocation = #_sourceLocation,
) {
    let uuidString = uuid.uuidString
    #expect(
        uuidString.count == 36,
        "UUID should be 36 characters long: \(uuidString)",
        sourceLocation: sourceLocation,
    )

    let uuidRegex = try! NSRegularExpression(
        pattern: "^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$",
        options: .caseInsensitive,
    )

    let range = NSRange(location: 0, length: uuidString.count)
    #expect(
        uuidRegex.firstMatch(in: uuidString, options: [], range: range) != nil,
        "UUID should match valid format: \(uuidString)",
        sourceLocation: sourceLocation,
    )
}

// MARK: - Performance Testing Helpers

/// Measure execution time of a block
func measureTime<T>(_ block: () throws -> T) rethrows -> (result: T, time: TimeInterval) {
    let startTime = CFAbsoluteTimeGetCurrent()
    let result = try block()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    return (result, timeElapsed)
}

/// Async version of measureTime
func measureTimeAsync<T>(_ block: () async throws -> T) async rethrows -> (result: T, time: TimeInterval) {
    let startTime = CFAbsoluteTimeGetCurrent()
    let result = try await block()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    return (result, timeElapsed)
}

// MARK: - Test Environment Helpers

/// Test environment configuration
enum TestEnvironment {
    static let isRunningTests: Bool = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
        ProcessInfo.processInfo.environment["SWIFT_TESTING"] != nil

    static let isUITesting: Bool = ProcessInfo.processInfo.arguments.contains("--uitesting")

    static let shouldDisableAnimations: Bool = ProcessInfo.processInfo.arguments.contains("--disable-animations")

    static let shouldResetState: Bool = ProcessInfo.processInfo.arguments.contains("--reset-state")
}

// MARK: - Memory Leak Detection

/// Helper to detect memory leaks in async operations
func withLeakDetection<T: AnyObject>(
    _ objectFactory: () -> T,
    operation: (T) async throws -> Void
) async throws {
    weak var weakObject: T?

    do {
        let object = objectFactory()
        weakObject = object
        try await operation(object)
        // object goes out of scope here
    }

    // Allow time for deallocation
    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

    #expect(weakObject == nil, "Object should have been deallocated (potential memory leak)")
}

// MARK: - Thread Safety Testing

/// Helper to test thread safety by performing concurrent operations
func testConcurrentAccess<T>(
    iterations: Int = 100,
    operation: @escaping () throws -> T
) async throws -> [T] {
    try await withThrowingTaskGroup(of: T.self) { group in
        for _ in 0 ..< iterations {
            group.addTask {
                try operation()
            }
        }

        var results: [T] = []
        for try await result in group {
            results.append(result)
        }
        return results
    }
}

// MARK: - File System Testing Helpers

/// Create a temporary directory for testing
func createTemporaryDirectory() throws -> URL {
    let tempDir = FileManager.default.temporaryDirectory
    let testDir = tempDir.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true)
    return testDir
}

/// Clean up temporary directory
func removeTemporaryDirectory(_ url: URL) {
    try? FileManager.default.removeItem(at: url)
}

/// Execute test with temporary directory cleanup
func withTemporaryDirectory<T>(_ operation: (URL) throws -> T) throws -> T {
    let tempDir = try createTemporaryDirectory()
    defer { removeTemporaryDirectory(tempDir) }
    return try operation(tempDir)
}
