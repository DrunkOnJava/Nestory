//
// Layer: App-Main
// Module: DamageAssessment/PhotoComparison/Components
// Purpose: Segmented picker for selecting photo type
//

import SwiftUI

public struct PhotoTypeSelector: View {
    @Binding public var selectedPhotoType: PhotoType
    
    public init(selectedPhotoType: Binding<PhotoType>) {
        self._selectedPhotoType = selectedPhotoType
    }
    
    public var body: some View {
        Picker("Photo Type", selection: $selectedPhotoType) {
            ForEach(PhotoType.allCases, id: \.self) { type in
                Label(type.rawValue, systemImage: type.systemImage)
                    .tag(type)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
}

#Preview {
    PhotoTypeSelector(selectedPhotoType: .constant(.before))
}