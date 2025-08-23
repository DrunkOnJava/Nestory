//
// Layer: Services
// Module: Services
// Purpose: Utility types for TCA dependency system
//

import Foundation

// MARK: - Thread-safe primitive for nonisolated access

/// Thread-safe container for values accessed from multiple isolation contexts
/// Used primarily for mock services that need to be accessed from TCA's background queues
final class LockIsolated<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Value
    
    init(_ value: Value) {
        self._value = value
    }
    
    var value: Value {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }
    
    func setValue(_ newValue: Value) {
        lock.lock()
        defer { lock.unlock() }
        _value = newValue
    }
}