//
// Layer: Services
// Module: AppStoreConnect
// Purpose: Data models and request/response types for app version operations
//

import Foundation

// MARK: - Request/Response Types

struct CreateVersionRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: Attributes
        let relationships: Relationships
    }

    struct Attributes: Encodable {
        let versionString: String
        let platform: String
    }

    struct Relationships: Encodable {
        let app: AppRelationship
    }

    struct AppRelationship: Encodable {
        let data: AppData
    }

    struct AppData: Encodable {
        let type: String
        let id: String
    }
}

struct UpdateVersionRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let id: String
        let attributes: Attributes
    }

    struct Attributes: Encodable {
        let releaseType: String?
        let earliestReleaseDate: Date?
    }
}

struct UpdateVersionLocalizationRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: Attributes
    }

    struct Attributes: Encodable {
        let description: String?
        let keywords: String?
        let marketingUrl: String?
        let promotionalText: String?
        let supportUrl: String?
        let whatsNew: String?
    }
}

struct SelectBuildRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let id: String
    }
}

struct CreateReviewSubmissionRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: Attributes
        let relationships: Relationships
    }

    struct Attributes: Encodable {
        let contactFirstName: String
        let contactLastName: String
        let contactEmail: String
        let contactPhone: String
        let demoAccountName: String?
        let demoAccountPassword: String?
        let demoAccountRequired: Bool
        let notes: String?
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

struct SubmitVersionRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let relationships: Relationships
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

struct AppVersionResponse: Decodable {
    let data: AppVersionData

    struct AppVersionData: Decodable {
        let id: String
        let attributes: Attributes

        struct Attributes: Decodable {
            let versionString: String
            let platform: String
            let appStoreState: String
            let releaseType: String?
            let earliestReleaseDate: String?
            let downloadable: Bool?
            let createdDate: String
        }
    }
}

struct AppVersionsResponse: Decodable {
    let data: [AppVersionResponse.AppVersionData]
}

struct BuildsResponse: Decodable {
    let data: [BuildData]

    struct BuildData: Decodable {
        let id: String
        let attributes: Attributes

        struct Attributes: Decodable {
            let version: String
            let uploadedDate: String
            let expirationDate: String
            let processingState: String
        }
    }
}
