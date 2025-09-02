//
// Layer: Features
// Module: Settings/Components
// Purpose: Receipt processing dashboard components
//

import SwiftUI
import Foundation

struct ReceiptProcessingComponent {
    
    @MainActor
    static func receiptProcessingDashboardView() -> some View {
        SettingsReceiptComponents.receiptProcessingDashboardView()
    }
}