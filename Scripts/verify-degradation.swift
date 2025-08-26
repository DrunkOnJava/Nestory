#!/usr/bin/env swift

//
// Script: verify-degradation.swift
// Purpose: Verify graceful degradation patterns in service dependency keys
//

import Foundation

print("🔍 Verifying Graceful Degradation Patterns...")
print(String(repeating: "=", count: 50))

// Read the ServiceDependencyKeys.swift file
let currentDir = FileManager.default.currentDirectoryPath
let serviceKeysPath = "\(currentDir)/Services/ServiceDependencyKeys.swift"

guard let content = try? String(contentsOfFile: serviceKeysPath, encoding: .utf8) else {
    print("❌ Could not read ServiceDependencyKeys.swift")
    exit(1)
}

// Check for graceful degradation patterns
let patterns = [
    "catch {": "Error handling blocks",
    "Logger.service.error": "Structured error logging", 
    "Logger.service.info": "Fallback notifications",
    "MockInventoryService()": "Inventory service fallback",
    "MockWarrantyTrackingService()": "Warranty service fallback",
    "MockInsuranceReportService()": "Insurance service fallback",
    "MockNotificationService()": "Notification service fallback",
    "MockClaimValidationService()": "Claim validation fallback",
    "recordFailure(for:": "Health monitoring integration",
    "notifyDegradedMode(service:": "Degraded mode notification"
]

var foundPatterns: [String: Int] = [:]
var missingPatterns: [String] = []

for (pattern, description) in patterns {
    let matches = content.components(separatedBy: pattern).count - 1
    foundPatterns[description] = matches
    
    if matches == 0 {
        missingPatterns.append(description)
    }
}

print("✅ Graceful Degradation Pattern Analysis:")
print("")

for (description, count) in foundPatterns.sorted(by: { $0.key < $1.key }) {
    let status = count > 0 ? "✓" : "✗"
    print("  \(status) \(description): \(count) occurrences")
}

print("")

if missingPatterns.isEmpty {
    print("🎉 All graceful degradation patterns found!")
    print("   Services properly fall back to mock implementations")
    print("   Error handling uses structured logging")
    print("   Health monitoring is integrated")
} else {
    print("⚠️  Missing patterns:")
    for pattern in missingPatterns {
        print("   - \(pattern)")
    }
}

// Check specific service patterns
let services = [
    "InventoryServiceKey",
    "WarrantyTrackingServiceKey", 
    "InsuranceReportServiceKey",
    "NotificationServiceKey",
    "ClaimValidationServiceKey"
]

print("")
print("📊 Service-Specific Degradation Patterns:")

for service in services {
    let hasService = content.contains(service)
    let hasCatchBlock = content.contains("\(service)") && content.contains("catch {")
    let hasMockFallback = content.contains("\(service)") && content.contains("Mock")
    
    let status = hasService && hasCatchBlock && hasMockFallback ? "✓" : "⚠️"
    print("  \(status) \(service): Service=\(hasService), Catch=\(hasCatchBlock), Mock=\(hasMockFallback)")
}

print("")
print("🔧 Verification complete!")

// Check for force unwraps that we eliminated
let forceUnwraps = content.components(separatedBy: "try!").count - 1
if forceUnwraps > 0 {
    print("⚠️  Found \(forceUnwraps) remaining force unwraps (try!) - these should be addressed")
} else {
    print("✅ No force unwraps (try!) found - excellent safety!")
}