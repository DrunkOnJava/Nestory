//
// Layer: Services
// Module: AppStoreConnect
// Purpose: Data models and request/response types for media upload operations
//

import Foundation

// MARK: - Request/Response Types

struct ScreenshotSetsResponse: Decodable {
    let data: [ScreenshotSetData]

    struct ScreenshotSetData: Decodable {
        let id: String
    }
}

struct ScreenshotSetResponse: Decodable {
    let data: ScreenshotSetData

    struct ScreenshotSetData: Decodable {
        let id: String
    }
}

struct PreviewSetsResponse: Decodable {
    let data: [PreviewSetData]

    struct PreviewSetData: Decodable {
        let id: String
    }
}

struct PreviewSetResponse: Decodable {
    let data: PreviewSetData

    struct PreviewSetData: Decodable {
        let id: String
    }
}

struct CreateScreenshotSetRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: Attributes
        let relationships: Relationships
    }

    struct Attributes: Encodable {
        let screenshotDisplayType: String
    }

    struct Relationships: Encodable {
        let appStoreVersionLocalization: LocalizationRelationship
    }

    struct LocalizationRelationship: Encodable {
        let data: LocalizationData
    }

    struct LocalizationData: Encodable {
        let type: String
        let id: String
    }
}

struct CreatePreviewSetRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let relationships: Relationships
    }

    struct Relationships: Encodable {
        let appStoreVersionLocalization: LocalizationRelationship
    }

    struct LocalizationRelationship: Encodable {
        let data: LocalizationData
    }

    struct LocalizationData: Encodable {
        let type: String
        let id: String
    }
}

struct ReserveScreenshotRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: Attributes
        let relationships: Relationships
    }

    struct Attributes: Encodable {
        let fileName: String
        let fileSize: Int
    }

    struct Relationships: Encodable {
        let appScreenshotSet: SetRelationship
    }

    struct SetRelationship: Encodable {
        let data: SetData
    }

    struct SetData: Encodable {
        let type: String
        let id: String
    }
}

struct ScreenshotUploadResponse: Decodable {
    let data: ScreenshotData

    struct ScreenshotData: Decodable {
        let id: String
        let attributes: Attributes

        struct Attributes: Decodable {
            let uploadOperations: [UploadOperation]?

            struct UploadOperation: Decodable {
                let url: String
                let method: String
                let requestHeaders: [Header]?

                struct Header: Decodable {
                    let name: String
                    let value: String
                }
            }
        }
    }
}

struct CommitScreenshotRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let id: String
        let attributes: Attributes
    }

    struct Attributes: Encodable {
        let uploaded: Bool
        let sourceFileChecksum: String?
    }
}

struct LocalizationsResponse: Decodable {
    let data: [LocalizationData]

    struct LocalizationData: Decodable {
        let id: String
    }
}

struct LocalizationResponse: Decodable {
    let data: LocalizationData

    struct LocalizationData: Decodable {
        let id: String
    }
}

struct CreateLocalizationRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: Attributes
        let relationships: Relationships
    }

    struct Attributes: Encodable {
        let locale: String
    }

    struct Relationships: Encodable {
        let appStoreVersion: VersionRelationship
    }

    struct VersionRelationship: Encodable {
        let data: VersionData
    }

    struct VersionData: Encodable {
        let type: String
        let id: String
    }
}
