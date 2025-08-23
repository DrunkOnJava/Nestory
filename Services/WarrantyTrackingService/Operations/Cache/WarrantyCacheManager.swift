//
// Layer: Services
// Module: WarrantyTrackingService/Operations/Cache
// Purpose: Performance-optimized caching for warranty data
//

import Foundation

/// Manages warranty data caching for performance optimization
public final class WarrantyCacheManager {
    
    private var warrantyCache: [UUID: Warranty] = [:]
    private var lastCacheUpdate: Date = .distantPast
    private let cacheExpiryInterval: TimeInterval
    
    public init(cacheExpiryInterval: TimeInterval = 300) { // 5 minutes default
        self.cacheExpiryInterval = cacheExpiryInterval
    }
    
    // MARK: - Cache Operations
    
    public func getWarranty(for itemId: UUID) -> Warranty? {
        guard isCacheValid() else {
            clearCache()
            return nil
        }
        
        return warrantyCache[itemId]
    }
    
    public func setWarranty(_ warranty: Warranty, for itemId: UUID) {
        warrantyCache[itemId] = warranty
        updateCacheTimestamp()
    }
    
    public func removeWarranty(for itemId: UUID) {
        warrantyCache.removeValue(forKey: itemId)
    }
    
    public func clearCache() {
        warrantyCache.removeAll()
        lastCacheUpdate = .distantPast
    }
    
    // MARK: - Cache Management
    
    private func isCacheValid() -> Bool {
        Date().timeIntervalSince(lastCacheUpdate) < cacheExpiryInterval
    }
    
    private func updateCacheTimestamp() {
        lastCacheUpdate = Date()
    }
    
    public func getCacheStatistics() -> CacheStatistics {
        CacheStatistics(
            itemCount: warrantyCache.count,
            lastUpdate: lastCacheUpdate,
            isValid: isCacheValid(),
            expiryInterval: cacheExpiryInterval
        )
    }
}

// MARK: - Supporting Types

public struct CacheStatistics {
    public let itemCount: Int
    public let lastUpdate: Date
    public let isValid: Bool
    public let expiryInterval: TimeInterval
    
    public init(itemCount: Int, lastUpdate: Date, isValid: Bool, expiryInterval: TimeInterval) {
        self.itemCount = itemCount
        self.lastUpdate = lastUpdate
        self.isValid = isValid
        self.expiryInterval = expiryInterval
    }
}