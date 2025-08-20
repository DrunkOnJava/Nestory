//
// Layer: Services
// Module: AppStoreConnect
// Purpose: Shared types for App Store Connect services
//

import Foundation

// Note: EmptyResponse is defined in NetworkClient.swift and imported via Infrastructure layer

// Common error types for App Store Connect services
enum AppStoreConnectError: LocalizedError {
    case invalidResponse
    case missingData
    case uploadFailed(String)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "Invalid response from App Store Connect"
        case .missingData:
            "Required data is missing"
        case let .uploadFailed(message):
            "Upload failed: \(message)"
        case let .apiError(message):
            "API error: \(message)"
        }
    }
}
