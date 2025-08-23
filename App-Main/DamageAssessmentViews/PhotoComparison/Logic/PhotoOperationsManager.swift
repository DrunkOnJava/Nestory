//
// Layer: App-Main
// Module: DamageAssessment/PhotoComparison/Logic
// Purpose: Photo operations manager with concurrency-safe data management
//

import Foundation

@MainActor
public final class PhotoOperationsManager: ObservableObject, @unchecked Sendable {
    
    // MARK: - Photo Management
    
    public func addPhoto(
        imageData: Data,
        type: PhotoType,
        description: String = "",
        to assessment: inout DamageAssessment
    ) {
        switch type {
        case .before:
            assessment.beforePhotos.append(imageData)
        case .after:
            assessment.afterPhotos.append(imageData)
        case .detail:
            assessment.detailPhotos.append(imageData)
            addDetailPhotoDescription(description, to: &assessment)
        }
    }
    
    public func removePhoto(
        type: PhotoType,
        index: Int,
        from assessment: inout DamageAssessment
    ) {
        switch type {
        case .before:
            removeBeforePhoto(at: index, from: &assessment)
        case .after:
            removeAfterPhoto(at: index, from: &assessment)
        case .detail:
            removeDetailPhoto(at: index, from: &assessment)
        }
    }
    
    // MARK: - Description Management
    
    public func getDetailPhotoDescription(
        index: Int,
        from assessment: DamageAssessment
    ) -> String {
        let descriptionIndex = assessment.beforePhotos.count + assessment.afterPhotos.count + index
        return assessment.photoDescriptions.indices.contains(descriptionIndex) ?
            assessment.photoDescriptions[descriptionIndex] : ""
    }
    
    // MARK: - Private Implementation
    
    private func addDetailPhotoDescription(_ description: String, to assessment: inout DamageAssessment) {
        guard !description.isEmpty else { return }
        
        let totalBeforeAfter = assessment.beforePhotos.count + assessment.afterPhotos.count
        let detailIndex = assessment.detailPhotos.count - 1
        let descriptionIndex = totalBeforeAfter + detailIndex
        
        // Ensure descriptions array is large enough
        while assessment.photoDescriptions.count <= descriptionIndex {
            assessment.photoDescriptions.append("")
        }
        
        assessment.photoDescriptions[descriptionIndex] = description
    }
    
    private func removeBeforePhoto(at index: Int, from assessment: inout DamageAssessment) {
        guard assessment.beforePhotos.indices.contains(index) else { return }
        
        assessment.beforePhotos.remove(at: index)
        // Remove corresponding description if it exists
        if assessment.photoDescriptions.indices.contains(index) {
            assessment.photoDescriptions.remove(at: index)
        }
    }
    
    private func removeAfterPhoto(at index: Int, from assessment: inout DamageAssessment) {
        guard assessment.afterPhotos.indices.contains(index) else { return }
        
        assessment.afterPhotos.remove(at: index)
        // Remove corresponding description
        let descriptionIndex = assessment.beforePhotos.count + index
        if assessment.photoDescriptions.indices.contains(descriptionIndex) {
            assessment.photoDescriptions.remove(at: descriptionIndex)
        }
    }
    
    private func removeDetailPhoto(at index: Int, from assessment: inout DamageAssessment) {
        guard assessment.detailPhotos.indices.contains(index) else { return }
        
        assessment.detailPhotos.remove(at: index)
        // Remove corresponding description
        let descriptionIndex = assessment.beforePhotos.count + assessment.afterPhotos.count + index
        if assessment.photoDescriptions.indices.contains(descriptionIndex) {
            assessment.photoDescriptions.remove(at: descriptionIndex)
        }
    }
    
    // MARK: - Validation
    
    public func hasPhotos(in assessment: DamageAssessment) -> Bool {
        !assessment.beforePhotos.isEmpty || 
        !assessment.afterPhotos.isEmpty || 
        !assessment.detailPhotos.isEmpty
    }
    
    public func photoCount(for type: PhotoType, in assessment: DamageAssessment) -> Int {
        switch type {
        case .before: assessment.beforePhotos.count
        case .after: assessment.afterPhotos.count
        case .detail: assessment.detailPhotos.count
        }
    }
}