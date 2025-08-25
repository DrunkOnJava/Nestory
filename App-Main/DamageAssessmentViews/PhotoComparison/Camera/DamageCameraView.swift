//
// Layer: App-Main
// Module: DamageAssessment/PhotoComparison/Camera
// Purpose: Camera interface for damage photo capture with concurrency safety
//

import SwiftUI
import UIKit

public struct DamageCameraView: UIViewControllerRepresentable {
    public let onCapture: @Sendable (Data) -> Void
    @Environment(\.dismiss) private var dismiss
    
    public init(onCapture: @escaping @Sendable (Data) -> Void) {
        self.onCapture = onCapture
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image"]
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    @MainActor
    public final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, @unchecked Sendable {
        let parent: DamageCameraView

        init(_ parent: DamageCameraView) {
            self.parent = parent
        }

        public func imagePickerController(
            _: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            Task { @MainActor in
                if let image = info[.originalImage] as? UIImage,
                   let imageData = image.jpegData(compressionQuality: 0.8)
                {
                    parent.onCapture(imageData)
                }
                parent.dismiss()
            }
        }

        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            Task { @MainActor in
                parent.dismiss()
            }
        }
    }
}