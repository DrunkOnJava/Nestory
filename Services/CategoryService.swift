//
// Layer: Services
// Module: CategoryService
// Purpose: Protocol-first category management service for TCA dependency injection
//

import ComposableArchitecture
import Foundation
import SwiftData

// MARK: - Protocol

public protocol CategoryService: Sendable {
    func fetchCategories() async throws -> [Category]
    func createCategory(name: String, icon: String, colorHex: String) async throws
    func updateCategory(_ category: Category) async throws
    func deleteCategory(_ category: Category) async throws
    func fetchItemsForCategory(_ categoryId: UUID) async throws -> [Item]
}

// MARK: - Live Implementation

public struct LiveCategoryService: CategoryService {
    private let inventoryService: InventoryService
    
    public init(inventoryService: InventoryService) {
        self.inventoryService = inventoryService
    }
    
    public func fetchCategories() async throws -> [Category] {
        return try await inventoryService.fetchCategories()
    }
    
    public func createCategory(name: String, icon: String, colorHex: String) async throws {
        let category = Category(name: name, icon: icon, colorHex: colorHex)
        try await inventoryService.saveCategory(category)
    }
    
    public func updateCategory(_ category: Category) async throws {
        // Category updates handled by direct model changes in SwiftData
        // The InventoryService doesn't have an updateCategory method, 
        // but since Category is a SwiftData model, changes are automatically tracked
    }
    
    public func deleteCategory(_ category: Category) async throws {
        // Delegate to InventoryService if it has delete functionality
        // For now, this is a placeholder - proper deletion would need to be added to InventoryService
        throw NSError(domain: "CategoryService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Delete not implemented"])
    }
    
    public func fetchItemsForCategory(_ categoryId: UUID) async throws -> [Item] {
        return try await inventoryService.fetchItemsByCategory(categoryId: categoryId)
    }
}

// MARK: - Mock Implementation

public struct MockCategoryService: CategoryService {
    public init() {}
    
    public func fetchCategories() async throws -> [Category] {
        return Category.createDefaultCategories()
    }
    
    public func createCategory(name: String, icon: String, colorHex: String) async throws {
        // Mock implementation - in real tests this would track state
    }
    
    public func updateCategory(_ category: Category) async throws {
        // Mock implementation
    }
    
    public func deleteCategory(_ category: Category) async throws {
        // Mock implementation
    }
    
    public func fetchItemsForCategory(_ categoryId: UUID) async throws -> [Item] {
        return []
    }
}

// MARK: - TCA Dependency Configuration
// 
// CategoryService dependency configuration is handled centrally in:
// - ServiceDependencyKeys.swift: CategoryServiceKey enum
// - DependencyValueExtensions.swift: DependencyValues.categoryService extension
//
// This ensures consistent dependency management across the app.