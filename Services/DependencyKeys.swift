//
// Layer: Services
// Module: Services
// Purpose: TCA dependency system - modular import of all dependency components
//

// MARK: - Modular Dependency System
//
// This file serves as the central import point for the modular TCA dependency system.
// The dependency system has been broken down into focused modules:
//
// - ServiceDependencyKeys.swift: All dependency key enums
// - DependencyValueExtensions.swift: DependencyValues computed properties
// - NotificationServiceCompatibility.swift: TCA concurrency compatibility layer
// - MockServiceImplementations.swift: All mock service implementations
// - DependencyUtilities.swift: Utility types like LockIsolated
//
// This modular approach provides better separation of concerns, easier maintenance,
// and cleaner import dependencies while preserving all existing functionality.

// Import all modular components
// The Swift compiler will automatically include these modules when this file is imported
// This maintains backward compatibility while providing a cleaner internal structure