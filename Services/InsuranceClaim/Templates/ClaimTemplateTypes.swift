//
// Layer: Services
// Module: InsuranceClaim/Templates
// Purpose: Core data structures for insurance claim templates
//

import Foundation
import UIKit

// MARK: - Core Template Types

public struct ClaimTemplate {
    public let id: UUID
    public var companyName: String
    public let claimType: ClaimType
    public let templateVersion: String
    public let logoData: Data?
    public var headerText: String
    public var requiredFields: [String]
    public let formSections: [FormSection]
    public var legalDisclaimer: String
    public let submissionInstructions: String
    public let contactInformation: String
    public var formatting: FormattingOptions

    public struct FormSection {
        public let title: String
        public let fields: [String]

        public init(title: String, fields: [String]) {
            self.title = title
            self.fields = fields
        }
    }

    public struct FormattingOptions {
        public let primaryColor: String
        public let secondaryColor: String
        public let fontFamily: String
        public let logoPosition: LogoPosition
        public let includeWatermark: Bool
        public let pageMargins: CGFloat

        public enum LogoPosition {
            case topLeft, topCenter, topRight
        }

        public init(
            primaryColor: String,
            secondaryColor: String,
            fontFamily: String,
            logoPosition: LogoPosition,
            includeWatermark: Bool,
            pageMargins: CGFloat
        ) {
            self.primaryColor = primaryColor
            self.secondaryColor = secondaryColor
            self.fontFamily = fontFamily
            self.logoPosition = logoPosition
            self.includeWatermark = includeWatermark
            self.pageMargins = pageMargins
        }
    }
}

public struct TemplateCustomizations {
    public let customHeaderText: String?
    public let customDisclaimer: String?
    public let additionalFields: [String]
    public let formatting: ClaimTemplate.FormattingOptions?

    public init(
        customHeaderText: String? = nil,
        customDisclaimer: String? = nil,
        additionalFields: [String] = [],
        formatting: ClaimTemplate.FormattingOptions? = nil
    ) {
        self.customHeaderText = customHeaderText
        self.customDisclaimer = customDisclaimer
        self.additionalFields = additionalFields
        self.formatting = formatting
    }
}