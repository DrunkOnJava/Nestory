//
// Layer: App-Main
// Module: DamageAssessment/PhotoComparison/Components
// Purpose: Photo description input field for detail photos
//

import SwiftUI

public struct PhotoDescriptionInput: View {
    @Binding public var photoDescription: String
    
    public init(photoDescription: Binding<String>) {
        self._photoDescription = photoDescription
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Photo Description")
                .font(.headline)
                .padding(.horizontal)

            Text("Describe what this detail photo shows")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            TextField("Enter description...", text: $photoDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
        }
    }
}

#Preview {
    PhotoDescriptionInput(photoDescription: .constant("Sample description"))
}