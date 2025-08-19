//
// Layer: Services
// Module: AppStoreConnect
// Purpose: Handle encryption export compliance declarations
//

import Foundation

/// Service for managing encryption declarations in App Store Connect
@MainActor
public final class EncryptionDeclarationService: ObservableObject {
    // MARK: - Types

    public struct EncryptionDeclaration: Codable {
        public let id: String?
        public let appId: String
        public let platform: String
        public let usesEncryption: Bool
        public let exempt: Bool
        public let containsProprietaryCode: Bool
        public let containsThirdPartyCode: Bool
        public let isExportComplianceRequired: Bool
        public let complianceCode: String?
        public let encryptionUpdated: Bool
        public let documentationUrl: String?

        public init(
            id: String? = nil,
            appId: String,
            platform: String = "IOS",
            usesEncryption: Bool = true,
            exempt: Bool = true,
            containsProprietaryCode: Bool = false,
            containsThirdPartyCode: Bool = false,
            isExportComplianceRequired: Bool = false,
            complianceCode: String? = nil,
            encryptionUpdated: Bool = false,
            documentationUrl: String? = nil
        ) {
            self.id = id
            self.appId = appId
            self.platform = platform
            self.usesEncryption = usesEncryption
            self.exempt = exempt
            self.containsProprietaryCode = containsProprietaryCode
            self.containsThirdPartyCode = containsThirdPartyCode
            self.isExportComplianceRequired = isExportComplianceRequired
            self.complianceCode = complianceCode
            self.encryptionUpdated = encryptionUpdated
            self.documentationUrl = documentationUrl
        }
    }

    public enum ComplianceStatus {
        case exempt // Uses only exempt encryption
        case compliant // Has proper documentation
        case pending // Awaiting review
        case required // Needs documentation
        case notApplicable // No encryption used
    }

    public struct ComplianceQuestionnaire {
        // Primary questions
        public let usesEncryption: Bool
        public let qualifiesForExemption: Bool

        // Detailed questions
        public let usesProprietaryEncryption: Bool
        public let usesStandardEncryption: Bool
        public let usesEncryptionForAuthentication: Bool
        public let usesEncryptionForSecureChannels: Bool
        public let usesEncryptionForCopyProtection: Bool
        public let availableOnlyInUSAndCanada: Bool

        // Nestory's default answers
        public static var nestoryCompliance: ComplianceQuestionnaire {
            ComplianceQuestionnaire(
                usesEncryption: true, // Yes, HTTPS and data protection
                qualifiesForExemption: true, // Yes, exempt under standard crypto
                usesProprietaryEncryption: false, // No custom algorithms
                usesStandardEncryption: true, // Yes, iOS standard crypto
                usesEncryptionForAuthentication: true, // Yes, keychain and Face ID
                usesEncryptionForSecureChannels: true, // Yes, HTTPS
                usesEncryptionForCopyProtection: false, // No DRM
                availableOnlyInUSAndCanada: false, // Worldwide distribution
            )
        }
    }

    // MARK: - Properties

    private let client: AppStoreConnectClient
    private var cachedDeclarations: [String: EncryptionDeclaration] = [:]

    // MARK: - Initialization

    public init(client: AppStoreConnectClient) {
        self.client = client
    }

    // MARK: - Declaration Management

    /// Create or update encryption declaration for an app
    public func submitDeclaration(
        appId: String,
        buildId: String,
        questionnaire: ComplianceQuestionnaire = .nestoryCompliance,
    ) async throws -> EncryptionDeclaration {
        // Determine compliance status based on questionnaire
        let isExempt = questionnaire.qualifiesForExemption &&
            !questionnaire.usesProprietaryEncryption &&
            questionnaire.usesStandardEncryption

        let declaration = EncryptionDeclaration(
            appId: appId,
            usesEncryption: questionnaire.usesEncryption,
            exempt: isExempt,
            containsProprietaryCode: questionnaire.usesProprietaryEncryption,
            containsThirdPartyCode: false,
            isExportComplianceRequired: !isExempt,
            complianceCode: isExempt ? nil : UUID().uuidString,
            encryptionUpdated: false,
        )

        // Submit to App Store Connect
        let request = APIRequest(
            path: "/v1/appEncryptionDeclarations",
            method: .post,
            body: CreateDeclarationRequest(
                data: CreateDeclarationRequest.Data(
                    type: "appEncryptionDeclarations",
                    attributes: CreateDeclarationRequest.Attributes(
                        usesEncryption: declaration.usesEncryption,
                        exempt: declaration.exempt,
                        containsProprietaryCode: declaration.containsProprietaryCode,
                        containsThirdPartyCode: declaration.containsThirdPartyCode,
                        isExportComplianceRequired: declaration.isExportComplianceRequired,
                        encryptionUpdated: declaration.encryptionUpdated,
                        complianceCode: declaration.complianceCode,
                    ),
                    relationships: CreateDeclarationRequest.Relationships(
                        app: CreateDeclarationRequest.AppRelationship(
                            data: CreateDeclarationRequest.AppData(
                                type: "apps",
                                id: appId,
                            ),
                        ),
                        builds: CreateDeclarationRequest.BuildsRelationship(
                            data: [CreateDeclarationRequest.BuildData(
                                type: "builds",
                                id: buildId,
                            )],
                        ),
                    ),
                ),
            ),
        )

        let response = try await client.execute(
            request,
            responseType: DeclarationResponse.self,
        )

        var updatedDeclaration = declaration
        if let responseId = response.data.id {
            updatedDeclaration = EncryptionDeclaration(
                id: responseId,
                appId: appId,
                usesEncryption: declaration.usesEncryption,
                exempt: declaration.exempt,
                containsProprietaryCode: declaration.containsProprietaryCode,
                containsThirdPartyCode: declaration.containsThirdPartyCode,
                isExportComplianceRequired: declaration.isExportComplianceRequired,
                complianceCode: declaration.complianceCode,
                encryptionUpdated: declaration.encryptionUpdated,
            )
        }

        // Cache the declaration
        cachedDeclarations[appId] = updatedDeclaration

        return updatedDeclaration
    }

    /// Get existing encryption declaration for an app
    public func getDeclaration(appId: String) async throws -> EncryptionDeclaration? {
        // Check cache first
        if let cached = cachedDeclarations[appId] {
            return cached
        }

        let request = APIRequest(
            path: "/v1/apps/\(appId)/appEncryptionDeclarations",
            queryParameters: [
                "limit": "1",
                "sort": "-createdDate",
            ],
        )

        let response = try await client.execute(
            request,
            responseType: DeclarationsResponse.self,
        )

        guard let data = response.data.first else {
            return nil
        }

        let declaration = mapToDeclaration(data, appId: appId)
        cachedDeclarations[appId] = declaration

        return declaration
    }

    /// Check compliance status for an app
    public func checkComplianceStatus(appId: String) async throws -> ComplianceStatus {
        guard let declaration = try await getDeclaration(appId: appId) else {
            return .required
        }

        if !declaration.usesEncryption {
            return .notApplicable
        }

        if declaration.exempt {
            return .exempt
        }

        if declaration.complianceCode != nil {
            return .compliant
        }

        return .required
    }

    /// Generate compliance documentation
    public func generateComplianceReport(
        appId: String,
        questionnaire: ComplianceQuestionnaire,
    ) -> String {
        var report = """
        EXPORT COMPLIANCE REPORT
        ========================
        Generated: \(Date())
        App ID: \(appId)

        ENCRYPTION USAGE SUMMARY
        ------------------------
        Uses Encryption: \(questionnaire.usesEncryption ? "YES" : "NO")
        Qualifies for Exemption: \(questionnaire.qualifiesForExemption ? "YES" : "NO")

        DETAILED RESPONSES
        ------------------
        Proprietary Encryption: \(questionnaire.usesProprietaryEncryption ? "YES" : "NO")
        Standard Encryption: \(questionnaire.usesStandardEncryption ? "YES" : "NO")
        Authentication: \(questionnaire.usesEncryptionForAuthentication ? "YES" : "NO")
        Secure Channels: \(questionnaire.usesEncryptionForSecureChannels ? "YES" : "NO")
        Copy Protection: \(questionnaire.usesEncryptionForCopyProtection ? "YES" : "NO")
        US/Canada Only: \(questionnaire.availableOnlyInUSAndCanada ? "YES" : "NO")

        COMPLIANCE STATUS
        -----------------
        """

        if questionnaire.qualifiesForExemption {
            report += """
            ✅ EXEMPT FROM EXPORT COMPLIANCE

            This app uses only standard encryption for:
            - HTTPS/TLS communications
            - iOS Data Protection API
            - Authentication services

            No export license or annual reporting required.
            """
        } else {
            report += """
            ⚠️ EXPORT COMPLIANCE REQUIRED

            This app requires export compliance documentation.
            Please consult with legal counsel regarding:
            - CCATS filing
            - Annual self-classification report
            - Export license requirements
            """
        }

        return report
    }

    // MARK: - Private Helpers

    private func mapToDeclaration(_ data: DeclarationsResponse.DeclarationData, appId: String) -> EncryptionDeclaration {
        EncryptionDeclaration(
            id: data.id,
            appId: appId,
            usesEncryption: data.attributes.usesEncryption ?? true,
            exempt: data.attributes.exempt ?? false,
            containsProprietaryCode: data.attributes.containsProprietaryCode ?? false,
            containsThirdPartyCode: data.attributes.containsThirdPartyCode ?? false,
            isExportComplianceRequired: data.attributes.isExportComplianceRequired ?? false,
            complianceCode: data.attributes.complianceCode,
            encryptionUpdated: data.attributes.encryptionUpdated ?? false,
        )
    }
}

// MARK: - Request/Response Types

private struct CreateDeclarationRequest: Encodable {
    let data: Data

    struct Data: Encodable {
        let type: String
        let attributes: Attributes
        let relationships: Relationships
    }

    struct Attributes: Encodable {
        let usesEncryption: Bool
        let exempt: Bool
        let containsProprietaryCode: Bool
        let containsThirdPartyCode: Bool
        let isExportComplianceRequired: Bool
        let encryptionUpdated: Bool
        let complianceCode: String?
    }

    struct Relationships: Encodable {
        let app: AppRelationship
        let builds: BuildsRelationship
    }

    struct AppRelationship: Encodable {
        let data: AppData
    }

    struct AppData: Encodable {
        let type: String
        let id: String
    }

    struct BuildsRelationship: Encodable {
        let data: [BuildData]
    }

    struct BuildData: Encodable {
        let type: String
        let id: String
    }
}

private struct DeclarationResponse: Decodable {
    let data: DeclarationData

    struct DeclarationData: Decodable {
        let id: String?
    }
}

private struct DeclarationsResponse: Decodable {
    let data: [DeclarationData]

    struct DeclarationData: Decodable {
        let id: String
        let attributes: Attributes

        struct Attributes: Decodable {
            let usesEncryption: Bool?
            let exempt: Bool?
            let containsProprietaryCode: Bool?
            let containsThirdPartyCode: Bool?
            let isExportComplianceRequired: Bool?
            let complianceCode: String?
            let encryptionUpdated: Bool?
        }
    }
}
