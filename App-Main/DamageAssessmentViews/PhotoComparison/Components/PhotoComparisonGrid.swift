//
// Layer: App-Main
// Module: DamageAssessment/PhotoComparison/Components
// Purpose: Grid component for displaying before/after/detail photos with concurrency safety
//

import SwiftUI

public struct PhotoComparisonGrid: View {
    public let assessment: DamageAssessment
    public let photoOperations: PhotoOperationsManager
    public let onRemovePhoto: @Sendable (PhotoType, Int) -> Void
    
    public init(
        assessment: DamageAssessment,
        photoOperations: PhotoOperationsManager,
        onRemovePhoto: @escaping @Sendable (PhotoType, Int) -> Void
    ) {
        self.assessment = assessment
        self.photoOperations = photoOperations
        self.onRemovePhoto = onRemovePhoto
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Before/After Comparison
            if !assessment.beforePhotos.isEmpty || !assessment.afterPhotos.isEmpty {
                beforeAfterSection
            }

            // Detail Photos
            if !assessment.detailPhotos.isEmpty {
                detailPhotosSection
            }
        }
    }
    
    // MARK: - Before/After Section
    
    private var beforeAfterSection: some View {
        HStack(spacing: 12) {
            // Before Photos
            VStack(alignment: .leading, spacing: 8) {
                Label("Before (\(assessment.beforePhotos.count))", systemImage: "photo")
                    .font(.caption)
                    .foregroundColor(.blue)

                if assessment.beforePhotos.isEmpty {
                    PhotoPlaceholderCard(type: .before)
                } else {
                    ForEach(0 ..< assessment.beforePhotos.count, id: \.self) { index in
                        PhotoCard(
                            imageData: assessment.beforePhotos[index],
                            type: .before,
                            description: getBeforePhotoDescription(index: index)
                        ) {
                            onRemovePhoto(.before, index)
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
                    PhotoPlaceholderCard(type: .after)
                } else {
                    ForEach(0 ..< assessment.afterPhotos.count, id: \.self) { index in
                        PhotoCard(
                            imageData: assessment.afterPhotos[index],
                            type: .after,
                            description: getAfterPhotoDescription(index: index)
                        ) {
                            onRemovePhoto(.after, index)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Detail Photos Section
    
    private var detailPhotosSection: some View {
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
                        description: photoOperations.getDetailPhotoDescription(
                            index: index,
                            from: assessment
                        )
                    ) {
                        onRemovePhoto(.detail, index)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getBeforePhotoDescription(index: Int) -> String {
        return assessment.photoDescriptions.indices.contains(index) ?
            assessment.photoDescriptions[index] : ""
    }
    
    private func getAfterPhotoDescription(index: Int) -> String {
        let descriptionIndex = assessment.beforePhotos.count + index
        return assessment.photoDescriptions.indices.contains(descriptionIndex) ?
            assessment.photoDescriptions[descriptionIndex] : ""
    }
}

#Preview {
    let assessment = DamageAssessment(
        itemId: UUID(),
        damageType: .fire,
        severity: .moderate,
        incidentDescription: "Test incident"
    )
    
    PhotoComparisonGrid(
        assessment: assessment,
        photoOperations: PhotoOperationsManager(),
        onRemovePhoto: { _, _ in }
    )
}