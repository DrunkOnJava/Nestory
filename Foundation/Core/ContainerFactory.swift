//
// Layer: Foundation
// Module: ContainerFactory
// Purpose: Centralized ModelContainer and ModelContext management with robust error handling
//

import SwiftData
import Foundation

/// Centralized factory for creating ModelContainer and ModelContext instances
/// with consistent error handling and fallback strategies
public final class ContainerFactory {
    public static let shared = ContainerFactory()
    
    private init() {}
    
    // MARK: - ModelContainer Creation
    
    /// Create a production ModelContainer with CloudKit support and multiple fallbacks
    public func createProductionContainer() -> ModelContainer {
        do {
            let schema = Schema([Item.self, Category.self, Room.self, Warranty.self, Receipt.self, ClaimSubmission.self])
            
            #if DEBUG
            // Development: Test with local-only first
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            #else
            // Production: Use CloudKit with private database
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private(Bundle.main.bundleIdentifier ?? "com.nestory.app")
            )
            #endif
            
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            Logger.service.error("Primary container creation failed: \(error.localizedDescription)")
            return createFallbackContainer()
        }
    }
    
    /// Create a local-only fallback ModelContainer
    public func createFallbackContainer() -> ModelContainer {
        do {
            let schema = Schema([Item.self, Category.self, Room.self, Warranty.self, Receipt.self, ClaimSubmission.self])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            Logger.service.error("Fallback container creation failed: \(error.localizedDescription)")
            return createInMemoryContainer()
        }
    }
    
    /// Create an in-memory ModelContainer for testing or emergency fallback
    public func createInMemoryContainer() -> ModelContainer {
        do {
            let schema = Schema([Item.self, Category.self, Room.self, Warranty.self, Receipt.self, ClaimSubmission.self])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            Logger.service.error("In-memory container creation failed: \(error.localizedDescription)")
            return createMinimalContainer()
        }
    }
    
    /// Create a minimal ModelContainer with only essential models
    public func createMinimalContainer() -> ModelContainer {
        do {
            let schema = Schema([Item.self])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            Logger.service.critical("Failed to create minimal container: \(error.localizedDescription)")
            // This should theoretically never fail, but if it does, we're in an unrecoverable state
            fatalError("Critical system failure: Cannot initialize any ModelContainer. App cannot continue.")
        }
    }
    
    /// Create a custom container for specific models and configuration
    public func createContainer(
        for models: [any PersistentModel.Type],
        isStoredInMemoryOnly: Bool = false,
        cloudKitDatabase: ModelConfiguration.CloudKitDatabase = .none
    ) throws -> ModelContainer {
        let schema = Schema(models)
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly,
            cloudKitDatabase: cloudKitDatabase
        )
        return try ModelContainer(for: schema, configurations: [config])
    }
    
    // MARK: - ModelContext Creation
    
    /// Create a ModelContext from a container with error handling
    public func createContext(from container: ModelContainer) -> ModelContext {
        return ModelContext(container)
    }
    
    /// Create a ModelContext with background actor isolation
    public func createBackgroundContext(from container: ModelContainer) -> ModelContext {
        let context = ModelContext(container)
        // Configure for background processing
        context.autosaveEnabled = true
        return context
    }
    
    // MARK: - Preview Helpers
    
    /// Create a safe preview container that won't crash on failure
    public static func createPreviewContainer() -> ModelContainer? {
        return try? ContainerFactory.shared.createContainer(
            for: [Item.self, Category.self, Warranty.self],
            isStoredInMemoryOnly: true
        )
    }
    
    /// Create preview container with sample data
    public static func createPreviewContainerWithData() -> (ModelContainer?, ModelContext?) {
        guard let container = createPreviewContainer() else {
            return (nil, nil)
        }
        
        let context = ModelContext(container)
        
        // Add sample data
        let category = Category(name: "Electronics", icon: "tv.fill", colorHex: "#007AFF")
        let item = Item(name: "Sample Item", itemDescription: "Preview item", quantity: 1, category: category)
        
        context.insert(category)
        context.insert(item)
        
        try? context.save()
        
        return (container, context)
    }
}

// MARK: - Convenience Extensions

extension ModelContainer {
    /// Create a container using the centralized factory
    public static func production() -> ModelContainer {
        return ContainerFactory.shared.createProductionContainer()
    }
    
    /// Create a fallback container using the centralized factory
    public static func fallback() -> ModelContainer {
        return ContainerFactory.shared.createFallbackContainer()
    }
    
    /// Create an in-memory container using the centralized factory
    public static func inMemory() -> ModelContainer {
        return ContainerFactory.shared.createInMemoryContainer()
    }
}

extension ModelContext {
    /// Create a context from the production container
    public static func production() -> ModelContext {
        return ContainerFactory.shared.createContext(from: .production())
    }
    
    /// Create a background context from the production container
    public static func background() -> ModelContext {
        return ContainerFactory.shared.createBackgroundContext(from: .production())
    }
}