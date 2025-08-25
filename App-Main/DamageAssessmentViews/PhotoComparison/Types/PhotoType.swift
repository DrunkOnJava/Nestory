//
// Layer: App-Main
// Module: DamageAssessment/PhotoComparison/Types
// Purpose: Photo type enumeration with UI properties for damage documentation
//

import SwiftUI

public enum PhotoType: String, CaseIterable, Sendable {
    case before = "Before"
    case after = "After"
    case detail = "Detail"

    public var systemImage: String {
        switch self {
        case .before: "photo"
        case .after: "photo.fill"
        case .detail: "magnifyingglass.circle"
        }
    }

    public var color: Color {
        switch self {
        case .before: .blue
        case .after: .red
        case .detail: .orange
        }
    }
    
    public var lowercasedTitle: String {
        self.rawValue.lowercased()
    }
}