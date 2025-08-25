//
// Layer: App-Main
// Module: ClaimPackageAssembly/Steps/PackageOptions
// Purpose: Photo inclusion toggles for package assembly
//

import SwiftUI

public struct IncludePhotosSection: View {
    @Binding public var includePhotos: Bool
    @Binding public var includeReceipts: Bool
    @Binding public var includeWarranties: Bool
    
    public init(
        includePhotos: Binding<Bool>,
        includeReceipts: Binding<Bool>,
        includeWarranties: Binding<Bool>
    ) {
        self._includePhotos = includePhotos
        self._includeReceipts = includeReceipts
        self._includeWarranties = includeWarranties
    }
    
    public var body: some View {
        Section("Include Photos") {
            Toggle("Item Photos", isOn: $includePhotos)
            Toggle("Receipts", isOn: $includeReceipts)
            Toggle("Warranties", isOn: $includeWarranties)
        }
    }
}

#Preview {
    Form {
        IncludePhotosSection(
            includePhotos: .constant(true),
            includeReceipts: .constant(true),
            includeWarranties: .constant(false)
        )
    }
}