//
// Layer: App-Main
// Module: DamageAssessment
// Purpose: Before and after photo comparison for damage documentation
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

    enum PhotoType: String, CaseIterable {
        case before = "Before"
        case after = "After"
        case detail = "Detail"

        var systemImage: String {
            switch self {
            case .before: "photo"
            case .after: "photo.fill"
            case .detail: "magnifyingglass.circle"
            }
        }

        var color: Color {
            switch self {
            case .before: .blue
            case .after: .red
            case .detail: .orange
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)

                        Text("Photo Documentation")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Capture before, after, and detail photos to document the damage")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    // Photo Type Selector
                    Picker("Photo Type", selection: $selectedPhotoType) {
                        ForEach(PhotoType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.systemImage)
                                .tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Photo Comparison Grid
                    photoComparisonGrid

                    // Photo Description Input
                    if selectedPhotoType == .detail {
                        photoDescriptionInput
                    }

                    // Action Buttons
                    actionButtons

                    // Photo Guidelines
                    photoGuidelines
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
                addPhoto(imageData: imageData)
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let newItem,
                   let data = try? await newItem.loadTransferable(type: Data.self)
                {
                    addPhoto(imageData: data)
                }
            }
        }
    }

    // MARK: - Photo Comparison Grid

    private var photoComparisonGrid: some View {
        VStack(spacing: 16) {
            // Before/After Comparison
            if !assessment.beforePhotos.isEmpty || !assessment.afterPhotos.isEmpty {
                HStack(spacing: 12) {
                    // Before Photos
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Before (\(assessment.beforePhotos.count))", systemImage: "photo")
                            .font(.caption)
                            .foregroundColor(.blue)

                        if assessment.beforePhotos.isEmpty {
                            placeholderPhotoCard(type: .before)
                        } else {
                            ForEach(0 ..< assessment.beforePhotos.count, id: \.self) { index in
                                PhotoCard(
                                    imageData: assessment.beforePhotos[index],
                                    type: .before,
                                    description: assessment.photoDescriptions.indices.contains(index) ?
                                        assessment.photoDescriptions[index] : ""
                                ) {
                                    removePhoto(type: .before, index: index)
                                }
                            }
                        }
                    }

                    // After Photos
                    VStack(alignment: .leading, spacing: 8) {
                        Label("After (\(assessment.afterPhotos.count))", systemImage: "photo.fill")
                            .font(.caption)
                            .foregroundColor(.red)

                        if assessment.afterPhotos.isEmpty {
                            placeholderPhotoCard(type: .after)
                        } else {
                            ForEach(0 ..< assessment.afterPhotos.count, id: \.self) { index in
                                PhotoCard(
                                    imageData: assessment.afterPhotos[index],
                                    type: .after,
                                    description: assessment.photoDescriptions.indices.contains(
                                        assessment.beforePhotos.count + index
                                    ) ? assessment.photoDescriptions[assessment.beforePhotos.count + index] : ""
                                ) {
                                    removePhoto(type: .after, index: index)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Detail Photos
            if !assessment.detailPhotos.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Detail Photos (\(assessment.detailPhotos.count))", systemImage: "magnifyingglass.circle")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 12) {
                        ForEach(0 ..< assessment.detailPhotos.count, id: \.self) { index in
                            PhotoCard(
                                imageData: assessment.detailPhotos[index],
                                type: .detail,
                                description: getDetailPhotoDescription(index: index)
                            ) {
                                removePhoto(type: .detail, index: index)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Photo Description Input

    private var photoDescriptionInput: some View {
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

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Camera Button
            Button(action: {
                showingCamera = true
            }) {
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
            Button(action: {
                showingPhotoPicker = true
            }) {
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

    // MARK: - Photo Guidelines

    private var photoGuidelines: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Photo Guidelines", systemImage: "info.circle")
                    .font(.headline)
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 8) {
                    GuidelineRow(
                        icon: "photo",
                        title: "Before Photos",
                        description: "Show the item's condition prior to damage if available"
                    )

                    GuidelineRow(
                        icon: "photo.fill",
                        title: "After Photos",
                        description: "Document current damaged condition from multiple angles"
                    )

                    GuidelineRow(
                        icon: "magnifyingglass.circle",
                        title: "Detail Photos",
                        description: "Close-up shots highlighting specific damage areas"
                    )
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Tips for Better Documentation:")
                        .font(.caption)
                        .fontWeight(.semibold)

                    Text("• Use good lighting and avoid shadows")
                        .font(.caption2)
                    Text("• Include reference objects for scale")
                        .font(.caption2)
                    Text("• Take photos from multiple angles")
                        .font(.caption2)
                    Text("• Focus clearly on damage areas")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Helper Views

    private func placeholderPhotoCard(type: PhotoType) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(.systemGray6))
            .frame(height: 100)
            .overlay(
                VStack {
                    Image(systemName: type.systemImage)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("No \(type.rawValue.lowercased()) photos")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            )
    }

    // MARK: - Actions

    private func addPhoto(imageData: Data) {
        switch selectedPhotoType {
        case .before:
            assessment.beforePhotos.append(imageData)
        case .after:
            assessment.afterPhotos.append(imageData)
        case .detail:
            assessment.detailPhotos.append(imageData)
            // Add description for detail photos
            if !photoDescription.isEmpty {
                let totalBeforeAfter = assessment.beforePhotos.count + assessment.afterPhotos.count
                let detailIndex = assessment.detailPhotos.count - 1
                let descriptionIndex = totalBeforeAfter + detailIndex

                // Ensure descriptions array is large enough
                while assessment.photoDescriptions.count <= descriptionIndex {
                    assessment.photoDescriptions.append("")
                }

                assessment.photoDescriptions[descriptionIndex] = photoDescription
                photoDescription = ""
            }
        }
    }

    private func removePhoto(type: PhotoType, index: Int) {
        switch type {
        case .before:
            if assessment.beforePhotos.indices.contains(index) {
                assessment.beforePhotos.remove(at: index)
                // Remove corresponding description if it exists
                if assessment.photoDescriptions.indices.contains(index) {
                    assessment.photoDescriptions.remove(at: index)
                }
            }
        case .after:
            if assessment.afterPhotos.indices.contains(index) {
                assessment.afterPhotos.remove(at: index)
                // Remove corresponding description
                let descriptionIndex = assessment.beforePhotos.count + index
                if assessment.photoDescriptions.indices.contains(descriptionIndex) {
                    assessment.photoDescriptions.remove(at: descriptionIndex)
                }
            }
        case .detail:
            if assessment.detailPhotos.indices.contains(index) {
                assessment.detailPhotos.remove(at: index)
                // Remove corresponding description
                let descriptionIndex = assessment.beforePhotos.count + assessment.afterPhotos.count + index
                if assessment.photoDescriptions.indices.contains(descriptionIndex) {
                    assessment.photoDescriptions.remove(at: descriptionIndex)
                }
            }
        }
    }

    private func getDetailPhotoDescription(index: Int) -> String {
        let descriptionIndex = assessment.beforePhotos.count + assessment.afterPhotos.count + index
        return assessment.photoDescriptions.indices.contains(descriptionIndex) ?
            assessment.photoDescriptions[descriptionIndex] : ""
    }
}

// MARK: - Supporting Views

struct PhotoCard: View {
    let imageData: Data
    let type: BeforeAfterPhotoComparisonView.PhotoType
    let description: String
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 100)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                }

                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(4)
            }

            if !description.isEmpty {
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

struct GuidelineRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Camera View

struct DamageCameraView: UIViewControllerRepresentable {
    let onCapture: (Data) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image"]
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: DamageCameraView

        init(_ parent: DamageCameraView) {
            self.parent = parent
        }

        func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let imageData = image.jpegData(compressionQuality: 0.8)
            {
                parent.onCapture(imageData)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            parent.dismiss()
        }
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
