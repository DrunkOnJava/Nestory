//
// Layer: Services
// Module: AppStoreConnect
// Purpose: Manage app metadata and configuration in App Store Connect
//

import Foundation

/// Service for managing app metadata in App Store Connect
@MainActor
public final class AppMetadataService: ObservableObject {
    // MARK: - Types

    public struct AppInfo: Codable, Identifiable {
        public let id: String
        public let bundleId: String
        public let name: String
        public let sku: String
        public let primaryLocale: String
        public var contentRightsDeclaration: ContentRightsDeclaration?

        public struct ContentRightsDeclaration: Codable {
            public let usesThirdPartyContent: Bool
            public let containsNaturalisticViolence: Bool
            public let containsRealisticViolence: Bool
            public let containsProlongedViolence: Bool
            public let containsSadisticViolence: Bool
            public let containsHorrorThemes: Bool
        }
    }

    public struct AppLocalizations: Codable {
        public let locale: String
        public var name: String
        public var subtitle: String?
        public var description: String
        public var keywords: String
        public var whatsNew: String?
        public var promotionalText: String?
        public var supportURL: String
        public var marketingURL: String?
        public var privacyPolicyURL: String?
        public var privacyPolicyText: String?
    }

    public struct AppCategories: Codable {
        public let primaryCategory: Category
        public let secondaryCategory: Category?

        public enum Category: String, Codable, CaseIterable {
            case business = "BUSINESS"
            case productivity = "PRODUCTIVITY"
            case utilities = "UTILITIES"
            case lifestyle = "LIFESTYLE"
            case finance = "FINANCE"
            case reference = "REFERENCE"
            case shopping = "SHOPPING"
            case photoVideo = "PHOTO_VIDEO"
            case news = "NEWS"
            case education = "EDUCATION"
        }
    }

    public struct AgeRating: Codable {
        public let ageRatingDeclaration: Declaration

        public struct Declaration: Codable {
            public let alcoholTobaccoOrDrugUseOrReferences: Level
            public let gamblingSimulated: Level
            public let horrorFearThemes: Level
            public let matureContent: Level
            public let medicalTreatmentInformation: Level
            public let profanityOrCrudeHumor: Level
            public let sexualContentGraphicAndNudity: Level
            public let sexualContentOrNudity: Level
            public let violenceCartoonOrFantasy: Level
            public let violenceRealistic: Level
            public let violenceRealisticProlongedGraphicOrSadistic: Level

            public enum Level: String, Codable {
                case none = "NONE"
                case infrequentOrMild = "INFREQUENT_OR_MILD"
                case frequentOrIntense = "FREQUENT_OR_INTENSE"
            }
        }
    }

    // MARK: - Properties

    private let client: AppStoreConnectClient
    private var cachedAppInfo: [String: AppInfo] = [:]

    // MARK: - Initialization

    public init(client: AppStoreConnectClient) {
        self.client = client
    }

    // MARK: - App Management

    /// Fetch app information
    public func fetchApp(bundleId: String) async throws -> AppInfo {
        // Check cache first
        if let cached = cachedAppInfo[bundleId] {
            return cached
        }

        let request = APIRequest(
            path: "/v1/apps",
            queryParameters: [
                "filter[bundleId]": bundleId,
                "fields[apps]": "bundleId,name,sku,primaryLocale",
            ],
        )

        let response = try await client.execute(
            request,
            responseType: AppsResponse.self,
        )

        guard let appData = response.data.first else {
            throw AppStoreConnectClient.APIError.invalidResponse
        }

        let appInfo = AppInfo(
            id: appData.id,
            bundleId: appData.attributes.bundleId,
            name: appData.attributes.name,
            sku: appData.attributes.sku,
            primaryLocale: appData.attributes.primaryLocale,
        )

        // Cache the result
        cachedAppInfo[bundleId] = appInfo

        return appInfo
    }

    /// Update app metadata
    public func updateAppMetadata(
        appId: String,
        localizations: [AppLocalizations],
    ) async throws {
        for localization in localizations {
            let request = APIRequest(
                path: "/v1/appInfoLocalizations",
                method: .patch,
                body: AppInfoLocalizationUpdateRequest(
                    data: AppInfoLocalizationUpdateRequest.Data(
                        type: "appInfoLocalizations",
                        id: appId,
                        attributes: AppInfoLocalizationUpdateRequest.Attributes(
                            name: localization.name,
                            subtitle: localization.subtitle,
                            privacyPolicyUrl: localization.privacyPolicyURL,
                            privacyPolicyText: localization.privacyPolicyText,
                        ),
                    ),
                ),
            )

            _ = try await client.execute(
                request,
                responseType: EmptyResponse.self,
            )
        }
    }

    /// Configure app categories
    public func updateCategories(
        appId: String,
        categories: AppCategories,
    ) async throws {
        let request = APIRequest(
            path: "/v1/apps/\(appId)",
            method: .patch,
            body: AppUpdateRequest(
                data: AppUpdateRequest.Data(
                    type: "apps",
                    id: appId,
                    attributes: AppUpdateRequest.Attributes(
                        primaryCategory: categories.primaryCategory.rawValue,
                        secondaryCategory: categories.secondaryCategory?.rawValue,
                        contentRightsDeclaration: nil
                    ),
                ),
            ),
        )

        _ = try await client.execute(
            request,
            responseType: EmptyResponse.self,
        )
    }

    /// Submit age rating declaration
    public func submitAgeRating(
        appId: String,
        rating: AgeRating,
    ) async throws {
        let request = APIRequest(
            path: "/v1/ageRatingDeclarations",
            method: .post,
            body: AgeRatingDeclarationCreateRequest(
                data: AgeRatingDeclarationCreateRequest.Data(
                    type: "ageRatingDeclarations",
                    attributes: rating.ageRatingDeclaration,
                    relationships: AgeRatingDeclarationCreateRequest.Relationships(
                        app: AgeRatingDeclarationCreateRequest.AppRelationship(
                            data: AgeRatingDeclarationCreateRequest.AppData(
                                type: "apps",
                                id: appId,
                            ),
                        ),
                    ),
                ),
            ),
        )

        _ = try await client.execute(
            request,
            responseType: EmptyResponse.self,
        )
    }

    /// Configure content rights
    public func updateContentRights(
        appId: String,
        usesThirdPartyContent: Bool,
    ) async throws {
        let request = APIRequest(
            path: "/v1/apps/\(appId)",
            method: .patch,
            body: AppUpdateRequest(
                data: AppUpdateRequest.Data(
                    type: "apps",
                    id: appId,
                    attributes: AppUpdateRequest.Attributes(
                        contentRightsDeclaration: AppUpdateRequest.ContentRights(
                            usesThirdPartyContent: usesThirdPartyContent,
                        ),
                    ),
                ),
            ),
        )

        _ = try await client.execute(
            request,
            responseType: EmptyResponse.self,
        )
    }
}

// MARK: - Response Types

private struct AppsResponse: Decodable {
    let data: [AppData]

    struct AppData: Decodable {
        let id: String
        let attributes: Attributes

        struct Attributes: Decodable {
            let bundleId: String
            let name: String
            let sku: String
            let primaryLocale: String
        }
    }
}

private struct AppInfoLocalizationUpdateRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let id: String
        let attributes: Attributes
    }

    struct Attributes: Encodable {
        let name: String?
        let subtitle: String?
        let privacyPolicyUrl: String?
        let privacyPolicyText: String?
    }
}

private struct AppUpdateRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let id: String
        let attributes: Attributes
    }

    struct Attributes: Encodable {
        let primaryCategory: String?
        let secondaryCategory: String?
        let contentRightsDeclaration: ContentRights?
    }

    struct ContentRights: Encodable {
        let usesThirdPartyContent: Bool
    }
}

private struct AgeRatingDeclarationCreateRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: AppMetadataService.AgeRating.Declaration
        let relationships: Relationships
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

private struct EmptyResponse: Decodable {}
