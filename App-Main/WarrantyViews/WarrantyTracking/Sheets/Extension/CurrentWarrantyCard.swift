//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/Extension
// Purpose: Current warranty information display card
//

import SwiftUI
import Foundation

public struct CurrentWarrantyCard: View {
    public let warranty: Warranty
    
    public init(warranty: Warranty) {
        self.warranty = warranty
    }
    
    public var body: some View {
        GroupBox("Current Warranty") {
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Provider", value: warranty.provider)
                
                InfoRow(
                    label: "Expires", 
                    value: DateFormatter.medium.string(from: warranty.expiresAt)
                )
                
                InfoRow(label: "Type", value: warranty.type.rawValue)
            }
        }
    }
}

#Preview {
    let warranty = Warranty(
        provider: "Apple Inc.",
        type: .manufacturer,
        startDate: Date(),
        expiresAt: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date(),
        item: Item(name: "iPhone 15 Pro", itemDescription: "Smartphone", quantity: 1)
    )
    
    CurrentWarrantyCard(warranty: warranty)
        .padding()
}

private struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}