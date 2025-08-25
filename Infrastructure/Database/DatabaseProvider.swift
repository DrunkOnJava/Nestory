//
// Layer: Infrastructure
// Module: Database
// Purpose: SwiftData abstraction for Services layer
//

import Foundation
import SwiftData

// MARK: - Database Provider Protocol

/// Abstract database provider interface for Services layer
/// Abstracts SwiftData specifics to enable testing and future migration
public protocol DatabaseProvider: Sendable {
    associatedtype Context
    
    /// Fetch entities matching the given descriptor
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) async throws -> [T]
    
    /// Insert a new entity
    func insert<T: PersistentModel>(_ entity: T) async throws
    
    /// Delete an entity
    func delete<T: PersistentModel>(_ entity: T) async throws
    
    /// Save changes to persistent storage
    func save() async throws
    
    /// Perform operations in a transaction
    func transaction<T>(_ operation: @escaping @Sendable (Context) async throws -> T) async throws -> T
    
    /// Get entity count matching predicate
    func count<T: PersistentModel>(for type: T.Type, predicate: Predicate<T>?) async throws -> Int
}

// MARK: - SwiftData Implementation

/// Live SwiftData implementation of DatabaseProvider
@MainActor
public final class SwiftDataProvider: DatabaseProvider {
    public typealias Context = ModelContext
    
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) async throws -> [T] {
        try modelContext.fetch(descriptor)
    }
    
    public func insert<T: PersistentModel>(_ entity: T) async throws {
        modelContext.insert(entity)
    }
    
    public func delete<T: PersistentModel>(_ entity: T) async throws {
        modelContext.delete(entity)
    }
    
    public func save() async throws {
        try modelContext.save()
    }
    
    public func transaction<T>(_ operation: @escaping @Sendable (ModelContext) async throws -> T) async throws -> T {
        try await operation(modelContext)
    }
    
    public func count<T: PersistentModel>(for type: T.Type, predicate: Predicate<T>?) async throws -> Int {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        let entities = try modelContext.fetch(descriptor)
        return entities.count
    }
}

// MARK: - Mock Implementation for Testing

/// Mock implementation for testing Services layer
public final class MockDatabaseProvider: DatabaseProvider {
    public typealias Context = Void
    
    private var entities: [String: [Any]] = [:]
    
    public init() {}
    
    public func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) async throws -> [T] {
        let typeName = String(describing: T.self)
        return (entities[typeName] as? [T]) ?? []
    }
    
    public func insert<T: PersistentModel>(_ entity: T) async throws {
        let typeName = String(describing: T.self)
        if entities[typeName] == nil {
            entities[typeName] = []
        }
        entities[typeName]?.append(entity)
    }
    
    public func delete<T: PersistentModel>(_ entity: T) async throws {
        let typeName = String(describing: T.self)
        // Mock deletion - remove from in-memory storage
        entities[typeName]?.removeAll { _ in true } // Simplified for mock
    }
    
    public func save() async throws {
        // Mock save - no-op for in-memory storage
    }
    
    public func transaction<T>(_ operation: @escaping @Sendable (Void) async throws -> T) async throws -> T {
        try await operation(())
    }
    
    public func count<T: PersistentModel>(for type: T.Type, predicate: Predicate<T>?) async throws -> Int {
        let typeName = String(describing: T.self)
        return entities[typeName]?.count ?? 0
    }
}