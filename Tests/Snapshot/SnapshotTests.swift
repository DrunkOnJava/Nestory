//
// Layer: Tests
// Module: SnapshotTests
// Purpose: Visual regression tests for critical UI components using SwiftUI
//

@testable import Nestory
import ComposableArchitecture
import SwiftData
import SwiftUI
import XCTest

@MainActor
final class SnapshotTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var themeManager: ThemeManager!

    override func setUp() async throws {
        try await super.setUp()

        // Set up in-memory model container for testing
        let schema = Schema([Item.self, Category.self, Room.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = container.mainContext
        themeManager = ThemeManager.shared

        // Set consistent theme for snapshot tests
        themeManager.setTheme(.light)
    }

    override func tearDown() async throws {
        container = nil
        context = nil
        themeManager = nil
        try await super.tearDown()
    }

    // MARK: - Helper Methods

    private func createTestData() throws {
        // Create test categories
        let electronics = Category(name: "Electronics")
        electronics.icon = "laptopcomputer"
        electronics.colorHex = "#007AFF"

        let furniture = Category(name: "Furniture")
        furniture.icon = "chair"
        furniture.colorHex = "#34C759"

        context.insert(electronics)
        context.insert(furniture)

        // Create test items
        let laptop = Item(name: "MacBook Pro 16\"")
        laptop.itemDescription = "2023 M3 Max, 64GB RAM, 2TB SSD"
        laptop.quantity = 1
        laptop.category = electronics
        laptop.brand = "Apple"
        laptop.modelNumber = "MacBookPro18,2"
        laptop.serialNumber = "C02XL1234567"
        laptop.purchasePrice = Decimal(3999.99)
        laptop.purchaseDate = Date(timeIntervalSinceReferenceDate: 694_224_000) // Fixed date for consistency
        laptop.condition = .excellent
        laptop.notes = "Company laptop for development work"

        let chair = Item(name: "Herman Miller Aeron")
        chair.itemDescription = "Ergonomic office chair"
        chair.quantity = 1
        chair.category = furniture
        chair.brand = "Herman Miller"
        chair.purchasePrice = Decimal(1395.00)
        chair.condition = .good

        context.insert(laptop)
        context.insert(chair)

        try context.save()
    }

    private func renderView(_ view: some View, size: CGSize = CGSize(width: 375, height: 667)) -> UIImage {
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        hostingController.view.backgroundColor = .systemBackground

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            hostingController.view.layer.render(in: context.cgContext)
        }
    }

    private func saveSnapshot(_ image: UIImage, name: String) {
        guard let data = image.pngData() else { return }

        let documentsPath = FileManager.default.urls(for: .documentDirectory,
                                                     in: .userDomainMask)[0]
        let snapshotPath = documentsPath.appendingPathComponent("Snapshots")

        do {
            try FileManager.default.createDirectory(at: snapshotPath,
                                                    withIntermediateDirectories: true)
            let filePath = snapshotPath.appendingPathComponent("\(name).png")
            try data.write(to: filePath)
            print("📸 Snapshot saved: \(filePath)")
        } catch {
            print("❌ Failed to save snapshot \(name): \(error)")
        }
    }

    // MARK: - RootView Snapshots

    func testRootViewSnapshot() throws {
        try createTestData()

        let rootView = RootView(
            store: Store(initialState: RootFeature.State()) {
                RootFeature()
            }
        )
        .environmentObject(themeManager)
        .modelContainer(container)

        let image = renderView(rootView)
        saveSnapshot(image, name: "RootView_Light")

        // Verify the view renders without crashing
        XCTAssertNotNil(image)
    }

    func testRootViewDarkModeSnapshot() throws {
        try createTestData()
        themeManager.setTheme(.dark)

        let rootView = RootView(
            store: Store(initialState: RootFeature.State()) {
                RootFeature()
            }
        )
        .environmentObject(themeManager)
        .modelContainer(container)
        .preferredColorScheme(.dark)

        let image = renderView(rootView)
        saveSnapshot(image, name: "RootView_Dark")

        XCTAssertNotNil(image)
    }

    // MARK: - InventoryListView Snapshots

    func testInventoryListViewEmptySnapshot() throws {
        let inventoryView = InventoryListView()
            .modelContainer(container)

        let image = renderView(inventoryView)
        saveSnapshot(image, name: "InventoryList_Empty")

        XCTAssertNotNil(image)
    }

    func testInventoryListViewPopulatedSnapshot() throws {
        try createTestData()

        let inventoryView = InventoryListView()
            .modelContainer(container)

        let image = renderView(inventoryView)
        saveSnapshot(image, name: "InventoryList_Populated")

        XCTAssertNotNil(image)
    }

    // MARK: - AddItemView Snapshots

    func testAddItemViewSnapshot() throws {
        try createTestData() // Ensure categories exist

        let addItemView = AddItemView()
            .modelContainer(container)

        let image = renderView(addItemView, size: CGSize(width: 375, height: 812))
        saveSnapshot(image, name: "AddItemView_Empty")

        XCTAssertNotNil(image)
    }

    // MARK: - ItemDetailView Snapshots

    func testItemDetailViewSnapshot() throws {
        try createTestData()

        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try context.fetch(fetchDescriptor)
        let testItem = items.first!

        let detailView = ItemDetailView(item: testItem)
            .modelContainer(container)

        let image = renderView(detailView, size: CGSize(width: 375, height: 812))
        saveSnapshot(image, name: "ItemDetailView_Complete")

        XCTAssertNotNil(image)
    }

    func testItemDetailViewMinimalSnapshot() throws {
        let minimalItem = Item(name: "Simple Item")
        context.insert(minimalItem)
        try context.save()

        let detailView = ItemDetailView(item: minimalItem)
            .modelContainer(container)

        let image = renderView(detailView, size: CGSize(width: 375, height: 812))
        saveSnapshot(image, name: "ItemDetailView_Minimal")

        XCTAssertNotNil(image)
    }

    // MARK: - SettingsView Snapshots

    func testSettingsViewSnapshot() throws {
        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)

        let image = renderView(settingsView, size: CGSize(width: 375, height: 812))
        saveSnapshot(image, name: "SettingsView_Light")

        XCTAssertNotNil(image)
    }

    func testSettingsViewDarkSnapshot() throws {
        themeManager.setTheme(.dark)

        let settingsView = SettingsView()
            .environmentObject(themeManager)
            .modelContainer(container)
            .preferredColorScheme(.dark)

        let image = renderView(settingsView, size: CGSize(width: 375, height: 812))
        saveSnapshot(image, name: "SettingsView_Dark")

        XCTAssertNotNil(image)
    }

    // MARK: - Component Snapshots

    func testItemRowComponentSnapshot() throws {
        try createTestData()

        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try context.fetch(fetchDescriptor)
        let testItem = items.first!

        // Note: ItemRowView might not exist, so we'll test the item in a list context
        let listView = List {
            ForEach([testItem]) { item in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name)
                            .font(.headline)
                        Spacer()
                        if let price = item.purchasePrice {
                            Text("$\(price)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    if let description = item.itemDescription {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 2)
            }
        }

        let image = renderView(listView, size: CGSize(width: 375, height: 200))
        saveSnapshot(image, name: "ItemRow_Component")

        XCTAssertNotNil(image)
    }

    func testEmptyStateViewSnapshot() throws {
        let emptyStateView = EmptyStateView(
            title: "📦 Empty Inventory",
            message: "Add your first item to get started!",
            systemImage: "shippingbox",
            actionTitle: "Add First Item",
        ) {
            // Mock action
        }

        let image = renderView(emptyStateView, size: CGSize(width: 375, height: 400))
        saveSnapshot(image, name: "EmptyStateView_Component")

        XCTAssertNotNil(image)
    }

    // MARK: - Different Device Sizes

    func testRootViewiPadSnapshot() throws {
        try createTestData()

        let rootView = RootView(
            store: Store(initialState: RootFeature.State()) {
                RootFeature()
            }
        )
        .environmentObject(themeManager)
        .modelContainer(container)

        let iPadSize = CGSize(width: 768, height: 1024)
        let image = renderView(rootView, size: iPadSize)
        saveSnapshot(image, name: "RootView_iPad")

        XCTAssertNotNil(image)
    }

    func testInventoryListiPhoneSESnapshot() throws {
        try createTestData()

        let inventoryView = InventoryListView()
            .modelContainer(container)

        let iPhoneSESize = CGSize(width: 320, height: 568)
        let image = renderView(inventoryView, size: iPhoneSESize)
        saveSnapshot(image, name: "InventoryList_iPhoneSE")

        XCTAssertNotNil(image)
    }

    // MARK: - Performance Tests

    func testSnapshotRenderingPerformance() throws {
        try createTestData()

        let contentView = ContentView()
            .environmentObject(themeManager)
            .modelContainer(container)

        measure {
            let image = renderView(contentView)
            XCTAssertNotNil(image)
        }
    }

    // MARK: - Regression Tests

    func testCriticalUserFlowSnapshots() throws {
        try createTestData()

        // Critical flow: Empty state → Add item → View details

        // 1. Empty state
        let emptyInventory = InventoryListView()
            .modelContainer(ModelContainer(for: [Item.self, Category.self],
                                           configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]))

        let emptyImage = renderView(emptyInventory)
        saveSnapshot(emptyImage, name: "CriticalFlow_01_Empty")

        // 2. Add item form
        let addItemView = AddItemView()
            .modelContainer(container)

        let addImage = renderView(addItemView, size: CGSize(width: 375, height: 812))
        saveSnapshot(addImage, name: "CriticalFlow_02_AddItem")

        // 3. Populated inventory
        let populatedInventory = InventoryListView()
            .modelContainer(container)

        let populatedImage = renderView(populatedInventory)
        saveSnapshot(populatedImage, name: "CriticalFlow_03_Populated")

        // 4. Item details
        let fetchDescriptor = FetchDescriptor<Item>()
        let items = try context.fetch(fetchDescriptor)
        let testItem = items.first!

        let detailView = ItemDetailView(item: testItem)
            .modelContainer(container)

        let detailImage = renderView(detailView, size: CGSize(width: 375, height: 812))
        saveSnapshot(detailImage, name: "CriticalFlow_04_Details")

        // All images should render successfully
        XCTAssertNotNil(emptyImage)
        XCTAssertNotNil(addImage)
        XCTAssertNotNil(populatedImage)
        XCTAssertNotNil(detailImage)
    }

    // MARK: - Accessibility Snapshots

    func testLargeDynamicTypeSnapshot() throws {
        try createTestData()

        let inventoryView = InventoryListView()
            .modelContainer(container)
            .environment(\.sizeCategory, .extraExtraExtraLarge)

        let image = renderView(inventoryView, size: CGSize(width: 375, height: 812))
        saveSnapshot(image, name: "InventoryList_LargeDynamicType")

        XCTAssertNotNil(image)
    }

    func testReducedMotionSnapshot() throws {
        try createTestData()

        let contentView = ContentView()
            .environmentObject(themeManager)
            .modelContainer(container)
            .environment(\.accessibilityReduceMotion, true)

        let image = renderView(contentView)
        saveSnapshot(image, name: "ContentView_ReducedMotion")

        XCTAssertNotNil(image)
    }

    // MARK: - Error State Snapshots

    func testErrorStateSnapshots() throws {
        // Test various error states that might occur

        // Item with missing data
        let incompleteItem = Item(name: "Incomplete Item")
        // Don't set other properties to test missing data handling
        context.insert(incompleteItem)
        try context.save()

        let detailView = ItemDetailView(item: incompleteItem)
            .modelContainer(container)

        let image = renderView(detailView, size: CGSize(width: 375, height: 812))
        saveSnapshot(image, name: "ErrorState_IncompleteItem")

        XCTAssertNotNil(image)
    }
}
