//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/Extension
// Purpose: Extension purchase action button with concurrency safety
//

import SwiftUI

public struct ExtensionPurchaseButton: View {
    public let onPurchase: @Sendable () -> Void
    
    public init(onPurchase: @escaping @Sendable () -> Void) {
        self.onPurchase = onPurchase
    }
    
    public var body: some View {
        Button(action: onPurchase) {
            HStack {
                Image(systemName: "cart.badge.plus")
                Text("Purchase Extension")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    ExtensionPurchaseButton(onPurchase: {})
        .padding()
}