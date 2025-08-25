//
// Layer: App-Main
// Module: ClaimPackageAssembly/Components
// Purpose: Validation check row component with status indicators
//

import SwiftUI

public struct ValidationCheckRow: View {
    public let title: String
    public let isValid: Bool
    public let detail: String
    
    public init(title: String, isValid: Bool, detail: String) {
        self.title = title
        self.isValid = isValid
        self.detail = detail
    }
    
    public var body: some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    List {
        ValidationCheckRow(
            title: "Items Selected",
            isValid: true,
            detail: "5 items"
        )
        
        ValidationCheckRow(
            title: "Item Photos",
            isValid: false,
            detail: "2/5 items have photos"
        )
    }
}