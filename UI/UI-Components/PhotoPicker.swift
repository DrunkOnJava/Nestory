//
// Layer: UI
// Module: UI-Components
// Purpose: Photo picker component for selecting images from photo library
//

import SwiftUI
import PhotosUI

struct PhotoPicker: View {
    @Binding var imageData: Data?
    @State private var selectedItem: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Select Photo", systemImage: "photo")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .onChange(of: selectedItem) { _, newValue in
                    Task {
                        if let item = newValue {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                await MainActor.run {
                                    imageData = data
                                    dismiss()
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle("Select Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PhotoPicker(imageData: .constant(nil))
}
