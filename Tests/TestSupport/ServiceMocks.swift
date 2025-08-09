// Layer: Tests
// Module: TestSupport
// Purpose: Service mocks for testing

import CloudKit
import ComposableArchitecture
import Foundation
import SwiftData
import UIKit

@testable import Nestory

public final class TestAuthService: AuthService {
    public var authenticateCalled = false
    public var authenticateResult: Result<AuthCredentials, Error>?

    public var validateBiometricCalled = false
    public var validateBiometricResult: Result<Bool, Error> = .success(true)

    public var signInCalled = false
    public var signInProvider: AuthProvider?
    public var signInResult: Result<AuthCredentials, Error>?

    public var signOutCalled = false
    public var signOutResult: Result<Void, Error> = .success(())

    public var refreshTokenCalled = false
    public var refreshTokenInput: String?
    public var refreshTokenResult: Result<AuthCredentials, Error>?

    public var currentUserCalled = false
    public var currentUserResult: AuthCredentials?

    public init() {}

    public func authenticate() async throws -> AuthCredentials {
        authenticateCalled = true
        if let result = authenticateResult {
            return try result.get()
        }
        return TestData.authCredentials
    }

    public func validateBiometric() async throws -> Bool {
        validateBiometricCalled = true
        return try validateBiometricResult.get()
    }

    public func signIn(with provider: AuthProvider) async throws -> AuthCredentials {
        signInCalled = true
        signInProvider = provider
        if let result = signInResult {
            return try result.get()
        }
        return TestData.authCredentials
    }

    public func signOut() async throws {
        signOutCalled = true
        try signOutResult.get()
    }

    public func refreshToken(_ token: String) async throws -> AuthCredentials {
        refreshTokenCalled = true
        refreshTokenInput = token
        if let result = refreshTokenResult {
            return try result.get()
        }
        return TestData.authCredentials
    }

    public func currentUser() async -> AuthCredentials? {
        currentUserCalled = true
        return currentUserResult
    }
}

public final class TestInventoryService: InventoryService {
    public var fetchItemsCalled = false
    public var fetchItemsResult: Result<[Item], Error> = .success([])

    public var fetchItemCalled = false
    public var fetchItemId: UUID?
    public var fetchItemResult: Item?

    public var saveItemCalled = false
    public var savedItem: Item?
    public var saveItemResult: Result<Void, Error> = .success(())

    public var updateItemCalled = false
    public var updatedItem: Item?
    public var updateItemResult: Result<Void, Error> = .success(())

    public var deleteItemCalled = false
    public var deletedItemId: UUID?
    public var deleteItemResult: Result<Void, Error> = .success(())

    public var searchItemsCalled = false
    public var searchQuery: String?
    public var searchItemsResult: Result<[Item], Error> = .success([])

    public init() {}

    public func fetchItems() async throws -> [Item] {
        fetchItemsCalled = true
        return try fetchItemsResult.get()
    }

    public func fetchItem(id: UUID) async throws -> Item? {
        fetchItemCalled = true
        fetchItemId = id
        return fetchItemResult
    }

    public func saveItem(_ item: Item) async throws {
        saveItemCalled = true
        savedItem = item
        try saveItemResult.get()
    }

    public func updateItem(_ item: Item) async throws {
        updateItemCalled = true
        updatedItem = item
        try updateItemResult.get()
    }

    public func deleteItem(id: UUID) async throws {
        deleteItemCalled = true
        deletedItemId = id
        try deleteItemResult.get()
    }

    public func searchItems(query: String) async throws -> [Item] {
        searchItemsCalled = true
        searchQuery = query
        return try searchItemsResult.get()
    }

    public func fetchCategories() async throws -> [Category] { [] }
    public func saveCategory(_: Category) async throws {}
    public func assignItemToCategory(itemId _: UUID, categoryId _: UUID) async throws {}
    public func fetchItemsByCategory(categoryId _: UUID) async throws -> [Item] { [] }
    public func bulkImport(items _: [Item]) async throws {}
    public func exportInventory(format _: ExportFormat) async throws -> Data { Data() }
}

public final class TestSyncService: SyncService {
    public var setupCloudKitCalled = false
    public var setupCloudKitResult: Result<Void, Error> = .success(())

    public var syncInventoryCalled = false
    public var syncInventoryResult: Result<SyncResult, Error> = .success(
        SyncResult(pushedCount: 0, pulledCount: 0, conflictsResolved: 0, timestamp: Date())
    )

    public var pushChangesCalled = false
    public var pushedChanges: [SyncChange] = []

    public var pullChangesCalled = false
    public var pullChangesSince: Date?
    public var pullChangesResult: Result<[SyncChange], Error> = .success([])

    public init() {}

    public func setupCloudKit() async throws {
        setupCloudKitCalled = true
        try setupCloudKitResult.get()
    }

    public func syncInventory() async throws -> SyncResult {
        syncInventoryCalled = true
        return try syncInventoryResult.get()
    }

    public func pushChanges(_ changes: [SyncChange]) async throws {
        pushChangesCalled = true
        pushedChanges = changes
    }

    public func pullChanges(since date: Date?) async throws -> [SyncChange] {
        pullChangesCalled = true
        pullChangesSince = date
        return try pullChangesResult.get()
    }

    public func resolveConflicts(_: [SyncConflict]) async throws {}
    public func createSubscription(for _: String) async throws {}
    public func fetchUserRecordID() async throws -> CKRecord.ID {
        CKRecord.ID(recordName: "test-user")
    }
}

public final class TestAnalyticsService: AnalyticsService {
    public var calculateTotalValueCalled = false
    public var calculateTotalValueItems: [Item] = []
    public var calculateTotalValueResult: Decimal = 0

    public var trackEventCalled = false
    public var trackedEvents: [AnalyticsEvent] = []

    public init() {}

    public func calculateTotalValue(for items: [Item]) async -> Decimal {
        calculateTotalValueCalled = true
        calculateTotalValueItems = items
        return calculateTotalValueResult
    }

    public func calculateCategoryBreakdown(for _: [Item]) async -> [CategoryBreakdown] { [] }
    public func calculateValueTrends(for _: [Item], period _: TrendPeriod) async -> [TrendPoint] { [] }
    public func calculateTopItems(from _: [Item], limit _: Int) async -> [Item] { [] }
    public func calculateDepreciation(for _: [Item]) async -> [DepreciationReport] { [] }

    public func generateDashboard(for items: [Item]) async -> DashboardData {
        DashboardData(
            totalItems: items.count,
            totalValue: calculateTotalValueResult,
            categoryBreakdown: [],
            topValueItems: [],
            recentItems: [],
            valueTrends: [],
            totalDepreciation: 0,
            lastUpdated: Date()
        )
    }

    public func trackEvent(_ event: AnalyticsEvent) async {
        trackEventCalled = true
        trackedEvents.append(event)
    }
}

public final class TestCurrencyService: CurrencyService {
    public var convertCalled = false
    public var convertAmount: Decimal?
    public var convertFrom: String?
    public var convertTo: String?
    public var convertResult: Result<Decimal, Error> = .success(100)

    public var updateRatesCalled = false
    public var updateRatesResult: Result<Void, Error> = .success(())

    public init() {}

    public func convert(amount: Decimal, from: String, to: String) async throws -> Decimal {
        convertCalled = true
        convertAmount = amount
        convertFrom = from
        convertTo = to
        return try convertResult.get()
    }

    public func updateRates() async throws {
        updateRatesCalled = true
        try updateRatesResult.get()
    }

    public func getRate(from _: String, to _: String) async throws -> Decimal { 1.0 }
    public func getSupportedCurrencies() async -> [Currency] { [] }
    public func getHistoricalRate(from _: String, to _: String, date _: Date) async throws -> Decimal? { 1.0 }
}

public enum TestData {
    public static let authCredentials = AuthCredentials(
        userId: "test-user-123",
        accessToken: "test-access-token",
        refreshToken: "test-refresh-token",
        expiresAt: Date().addingTimeInterval(3600),
        provider: .demo
    )

    public static func makeItem(
        id _: UUID = UUID(),
        name: String = "Test Item",
        purchasePrice: Decimal? = 99.99,
        quantity: Int = 1
    ) -> Item {
        let item = Item(name: name)
        item.purchasePrice = purchasePrice
        item.quantity = quantity
        return item
    }

    public static func makeCategory(name: String = "Test Category") -> Category {
        Category(name: name)
    }
}
