//
// Layer: App-Main
// Module: DamageAssessment/PhotoComparison/Components
// Purpose: Action buttons for camera and photo library access
//

import SwiftUI

public struct PhotoActionButtons: View {
    public let selectedPhotoType: PhotoType
    public let onCameraAction: @Sendable () -> Void
    public let onPhotoLibraryAction: @Sendable () -> Void
    
    public init(
        selectedPhotoType: PhotoType,
        onCameraAction: @escaping @Sendable () -> Void,
        onPhotoLibraryAction: @escaping @Sendable () -> Void
    ) {
        self.selectedPhotoType = selectedPhotoType
        self.onCameraAction = onCameraAction
        self.onPhotoLibraryAction = onPhotoLibraryAction
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // Camera Button
            Button(action: onCameraAction) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Camera")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedPhotoType.color.opacity(0.1))
                .foregroundColor(selectedPhotoType.color)
                .cornerRadius(12)
            }

            // Photo Library Button
            Button(action: onPhotoLibraryAction) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Photo Library")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedPhotoType.color.opacity(0.1))
                .foregroundColor(selectedPhotoType.color)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    PhotoActionButtons(
        selectedPhotoType: .before,
        onCameraAction: {},
        onPhotoLibraryAction: {}
    )
}