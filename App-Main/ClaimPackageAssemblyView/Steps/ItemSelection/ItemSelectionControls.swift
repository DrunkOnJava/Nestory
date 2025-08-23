//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/ItemSelection
// Purpose: Selection control header with bulk operations
//

import SwiftUI

public struct ItemSelectionControls: View {
    public let selectedCount: Int
    public let totalCount: Int
    public let onSelectAll: @Sendable () -> Void
    public let onClearAll: @Sendable () -> Void
    
    public init(
        selectedCount: Int,
        totalCount: Int,
        onSelectAll: @escaping @Sendable () -> Void,
        onClearAll: @escaping @Sendable () -> Void
    ) {
        self.selectedCount = selectedCount
        self.totalCount = totalCount
        self.onSelectAll = onSelectAll
        self.onClearAll = onClearAll
    }
    
    public var body: some View {
        HStack {
            Text("\(selectedCount) of \(totalCount) selected")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("All", action: onSelectAll)
                .font(.caption)
            
            Button("None", action: onClearAll)
                .font(.caption)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

#Preview {
    ItemSelectionControls(
        selectedCount: 3,
        totalCount: 10,
        onSelectAll: {},
        onClearAll: {}
    )
}