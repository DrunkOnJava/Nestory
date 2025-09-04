//
// Layer: Foundation
// Module: Core/ContainerFactory
// Purpose: Factory for creating and configuring ModelContainer instances with error handling
//

import Foundation
import SwiftData

public struct ContainerFactory {
    
    public static func createContainer() -> ModelContainer {
        do {
            let container = try ModelContainer(for: Item.self, configurations: createConfiguration())
            return container
        } catch {
            // Log error and return fallback container
            print("Failed to create ModelContainer: \(error.localizedDescription)")
            return createFallbackContainer()
        }
    }
    
    public static func createPreviewContainer() -> ModelContainer {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            return try ModelContainer(for: Item.self, configurations: config)
        } catch {
            print("Failed to create preview container: \(error.localizedDescription)")
            return createFallbackContainer()
        }
    }
    
    public static func createTestContainer() -> ModelContainer {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            return try ModelContainer(for: Item.self, configurations: config)
        } catch {
            print("Failed to create test container: \(error.localizedDescription)")
            return createFallbackContainer()
        }
    }
    
    private static func createConfiguration() -> ModelConfiguration {
        #if DEBUG
        return ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true)
        #else
        return ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true)
        #endif
    }
    
    private static func createFallbackContainer() -> ModelContainer {
        do {
            // Try in-memory fallback
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            return try ModelContainer(for: Item.self, configurations: config)
        } catch {
            // This should never happen, but provide ultimate fallback
            fatalError("Unable to create any ModelContainer: \(error)")
        }
    }
}

public extension ContainerFactory {
    
    static func configureCloudKit() -> ModelConfiguration {
        #if DEBUG
        // Use development environment for debug builds
        return ModelConfiguration(
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .automatic
        )
        #else
        // Use production environment for release builds
        return ModelConfiguration(
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .automatic
        )
        #endif
    }
    
    static func createCloudKitContainer() -> ModelContainer {
        do {
            let config = configureCloudKit()
            return try ModelContainer(for: Item.self, configurations: config)
        } catch {
            print("Failed to create CloudKit container: \(error.localizedDescription)")
            print("Falling back to local-only storage")
            return createContainer()
        }
    }
}

// MARK: - Container Health Check

public extension ContainerFactory {
    
    static func validateContainer(_ container: ModelContainer) -> Bool {
        do {
            let context = ModelContext(container)
            // Try a simple operation to verify the container is working
            let descriptor = FetchDescriptor<Item>()
            _ = try context.fetchCount(descriptor)
            return true
        } catch {
            print("Container validation failed: \(error.localizedDescription)")
            return false
        }
    }
    
    static func repairContainer(_ container: ModelContainer) -> ModelContainer? {
        // Attempt to repair the container by recreating it
        do {
            let newContainer = createContainer()
            if validateContainer(newContainer) {
                return newContainer
            }
        } catch {
            print("Container repair failed: \(error.localizedDescription)")
        }
        return nil
    }
}