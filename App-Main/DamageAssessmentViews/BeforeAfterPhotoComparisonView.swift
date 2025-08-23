//
// Layer: App-Main
// Module: DamageAssessment
// Purpose: Before and after photo comparison for damage documentation - Modularized Architecture
//

import SwiftUI
import PhotosUI

struct BeforeAfterPhotoComparisonView: View {
    @Binding var assessment: DamageAssessment
    @State private var selectedPhotoType: PhotoType = .before
    @State private var showingPhotoPicker = false
    @State private var showingCamera = false
    @State private var photoDescription = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss
    
    // Photo operations manager
    @StateObject private var photoOperations = PhotoOperationsManager()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    PhotoComparisonHeader()

                    // Photo Type Selector
                    PhotoTypeSelector(selectedPhotoType: $selectedPhotoType)

                    // Photo Comparison Grid
                    PhotoComparisonGrid(
                        assessment: assessment,
                        photoOperations: photoOperations,
                        onRemovePhoto: { photoType, index in
                            Task { @MainActor in
                                removePhoto(type: photoType, index: index)
                            }
                        }
                    )

                    // Photo Description Input
                    if selectedPhotoType == .detail {
                        PhotoDescriptionInput(photoDescription: $photoDescription)
                    }

                    // Action Buttons
                    PhotoActionButtons(
                        selectedPhotoType: selectedPhotoType,
                        onCameraAction: {
                            Task { @MainActor in
                                showingCamera = true
                            }
                        },
                        onPhotoLibraryAction: {
                            Task { @MainActor in
                                showingPhotoPicker = true
                            }
                        }
                    )

                    // Photo Guidelines
                    PhotoGuidelines()
                }
                .padding(.vertical)
            }
            .navigationTitle("Photo Documentation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .photosPicker(
            isPresented: $showingPhotoPicker,
            selection: $selectedPhoto,
            matching: .images,
            photoLibrary: .shared()
        )
        .fullScreenCover(isPresented: $showingCamera) {
            DamageCameraView { imageData in
                Task { @MainActor in
                    addPhoto(imageData: imageData)
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task { @MainActor in
                if let newItem,
                   let data = try? await newItem.loadTransferable(type: Data.self)
                {
                    addPhoto(imageData: data)
                }
            }
        }
    }

    // MARK: - Business Logic Methods

    @MainActor
    private func addPhoto(imageData: Data) {
        photoOperations.addPhoto(
            imageData: imageData,
            type: selectedPhotoType,
            description: photoDescription,
            to: &assessment
        )
        
        // Clear description after adding detail photo
        if selectedPhotoType == .detail {
            photoDescription = ""
        }
    }
    
    @MainActor
    private func removePhoto(type: PhotoType, index: Int) {
        photoOperations.removePhoto(
            type: type,
            index: index,
            from: &assessment
        )
    }
}


#Preview {
    BeforeAfterPhotoComparisonView(
        assessment: .constant(DamageAssessment(
            itemId: UUID(),
            damageType: .fire,
            severity: .moderate,
            incidentDescription: "Fire damage from kitchen incident"
        ))
    )
}
