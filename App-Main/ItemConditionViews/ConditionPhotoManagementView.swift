//
//  ConditionPhotoManagementView.swift
//  Nestory
//
//  Photo management for condition documentation
//

import PhotosUI
import SwiftData
import SwiftUI

struct ConditionPhotoManagementView: View {
    @Bindable var item: Item
    @Binding var photoDescriptions: [String]
    @State private var showingPhotoPicker = false
    @State private var showingCamera = false
    @State private var selectedPhotoIndex: Int?
    @State private var showingDeleteAlert = false
    @State private var photoToDelete: Int?
    @State private var selectedImageData: Data?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Condition Photos")
                    .font(.headline)

                Spacer()

                Menu {
                    Button(action: { showingCamera = true }) {
                        Label("Take Photo", systemImage: "camera")
                    }

                    Button(action: { showingPhotoPicker = true }) {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
            }

            if item.conditionPhotos.isEmpty {
                ConditionPhotoEmptyState(
                    showingCamera: $showingCamera,
                )
            } else {
                ConditionPhotoGrid(
                    photos: item.conditionPhotos,
                    descriptions: photoDescriptions,
                    selectedPhotoIndex: $selectedPhotoIndex,
                    photoToDelete: $photoToDelete,
                    showingDeleteAlert: $showingDeleteAlert,
                )
            }

            Text("\(item.conditionPhotos.count) photo\(item.conditionPhotos.count == 1 ? "" : "s") documenting condition")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .sheet(isPresented: $showingCamera) {
            PhotoCaptureView(imageData: $selectedImageData)
                .onDisappear {
                    if let data = selectedImageData {
                        item.conditionPhotos.append(data)
                        photoDescriptions.append("")
                        selectedImageData = nil
                    }
                }
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerView(imageData: $selectedImageData)
                .onDisappear {
                    if let data = selectedImageData {
                        item.conditionPhotos.append(data)
                        photoDescriptions.append("")
                        selectedImageData = nil
                    }
                }
        }
        .sheet(isPresented: Binding(
            get: { selectedPhotoIndex != nil },
            set: { if !$0 { selectedPhotoIndex = nil } },
        )) {
            if let index = selectedPhotoIndex {
                ConditionPhotoDetailView(
                    photoData: item.conditionPhotos[index],
                    description: Binding(
                        get: { photoDescriptions[safe: index] ?? "" },
                        set: { newValue in
                            while photoDescriptions.count <= index {
                                photoDescriptions.append("")
                            }
                            photoDescriptions[index] = newValue
                        },
                    ),
                )
            }
        }
        .alert("Delete Photo?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let index = photoToDelete {
                    deletePhoto(at: index)
                }
            }
        } message: {
            Text("This photo will be permanently removed from the condition documentation.")
        }
    }

    private func deletePhoto(at index: Int) {
        guard index < item.conditionPhotos.count else { return }
        item.conditionPhotos.remove(at: index)
        if index < photoDescriptions.count {
            photoDescriptions.remove(at: index)
        }
    }
}

struct ConditionPhotoEmptyState: View {
    @Binding var showingCamera: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.on.rectangle")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No condition photos yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Add photos to document current condition")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: { showingCamera = true }) {
                Label("Add First Photo", systemImage: "camera.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ConditionPhotoGrid: View {
    let photos: [Data]
    let descriptions: [String]
    @Binding var selectedPhotoIndex: Int?
    @Binding var photoToDelete: Int?
    @Binding var showingDeleteAlert: Bool

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
            ForEach(Array(photos.enumerated()), id: \.offset) { index, photoData in
                ConditionPhotoCard(
                    photoData: photoData,
                    description: descriptions[safe: index] ?? "",
                    onTap: { selectedPhotoIndex = index },
                    onDelete: {
                        photoToDelete = index
                        showingDeleteAlert = true
                    },
                )
            }
        }
    }
}

struct ConditionPhotoCard: View {
    let photoData: Data
    let description: String
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                if let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1),
                        )
                }
            }
            .buttonStyle(.plain)

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .background(Circle().fill(.white))
            }
            .offset(x: 8, y: -8)
        }
    }
}

struct ConditionPhotoDetailView: View {
    let photoData: Data
    @Binding var description: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                if let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                }

                Form {
                    Section("Photo Description") {
                        TextField("Describe what this photo shows", text: $description, axis: .vertical)
                            .lineLimit(3 ... 6)
                    }
                }
            }
            .navigationTitle("Condition Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: PHPickerViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        func picker(_: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                guard let uiImage = image as? UIImage,
                      let data = uiImage.jpegData(compressionQuality: 0.8) else { return }

                DispatchQueue.main.async {
                    self.parent.imageData = data
                }
            }
        }
    }
}
