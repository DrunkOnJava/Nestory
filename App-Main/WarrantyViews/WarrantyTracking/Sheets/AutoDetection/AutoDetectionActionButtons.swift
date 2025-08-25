//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/AutoDetection
// Purpose: Action buttons for auto-detection acceptance with concurrency safety
//

import SwiftUI

public struct AutoDetectionActionButtons: View {
    public let onAccept: @Sendable () -> Void
    public let onReject: @Sendable () -> Void
    
    public init(
        onAccept: @escaping @Sendable () -> Void,
        onReject: @escaping @Sendable () -> Void
    ) {
        self.onAccept = onAccept
        self.onReject = onReject
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Button(action: onAccept) {
                HStack {
                    Image(systemName: "checkmark")
                    Text("Accept & Apply Warranty")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Button(action: onReject) {
                Text("Decline")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    AutoDetectionActionButtons(
        onAccept: {},
        onReject: {}
    )
    .padding()
}