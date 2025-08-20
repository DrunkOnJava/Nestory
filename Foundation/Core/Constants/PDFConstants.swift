//
// Layer: Foundation
// Module: Core/Constants
// Purpose: PDF layout and formatting constants for insurance reports
//

import CoreGraphics
import Foundation

/// PDF constants for consistent report generation and layout
public enum PDFConstants {
    /// Font sizes for PDF elements
    public enum FontSize {
        /// Title font size (24pt)
        public static let title: CGFloat = 24

        /// Section header font size (16pt)
        public static let sectionHeader: CGFloat = 16

        /// Category header font size (14pt)
        public static let categoryHeader: CGFloat = 14

        /// Item name font size (12pt)
        public static let itemName: CGFloat = 12

        /// Body text font size (12pt)
        public static let body: CGFloat = 12

        /// Detail text font size (10pt)
        public static let detail: CGFloat = 10
    }

    /// Page margins and positioning
    public enum Margin {
        /// Left margin (50pt)
        public static let left: CGFloat = 50

        /// Right margin (50pt)
        public static let right: CGFloat = 50

        /// Top margin (50pt)
        public static let top: CGFloat = 50

        /// Bottom margin (50pt)
        public static let bottom: CGFloat = 50
    }

    /// Vertical spacing between elements
    public enum Spacing {
        /// Small spacing (10pt)
        public static let small: CGFloat = 10

        /// Medium spacing (15pt)
        public static let medium: CGFloat = 15

        /// Large spacing (20pt)
        public static let large: CGFloat = 20

        /// Extra large spacing (25pt)
        public static let extraLarge: CGFloat = 25

        /// Section spacing (30pt)
        public static let section: CGFloat = 30

        /// Title spacing below (45pt)
        public static let titleBelow: CGFloat = 45

        /// Subtitle spacing below (60pt)
        public static let subtitleBelow: CGFloat = 60
    }

    /// Horizontal indentation levels
    public enum Indent {
        /// No indentation (50pt - same as left margin)
        public static let none: CGFloat = Margin.left

        /// Category indentation (60pt)
        public static let category: CGFloat = 60

        /// Item indentation (70pt)
        public static let item: CGFloat = 70

        /// Item name indentation (80pt)
        public static let itemName: CGFloat = 80

        /// Detail indentation (90pt)
        public static let detail: CGFloat = 90
    }

    /// Line heights for different text elements
    public enum LineHeight {
        /// Title line advancement (30pt)
        public static let title: CGFloat = 30

        /// Body text line advancement (18pt)
        public static let body: CGFloat = 18

        /// Item line advancement (16pt)
        public static let item: CGFloat = 16

        /// Detail line advancement (14pt)
        public static let detail: CGFloat = 14
    }

    /// Page break thresholds
    public enum PageBreak {
        /// Minimum space before page break for sections (150pt)
        public static let sectionMinimum: CGFloat = 150

        /// Minimum space before page break for items (100pt)
        public static let itemMinimum: CGFloat = 100
    }

    /// Text content limits
    public enum Content {
        /// Maximum description length before truncation
        public static let maxDescriptionLength = 100

        /// Truncation suffix
        public static let truncationSuffix = "..."
    }

    /// Standard page dimensions (US Letter)
    public enum PageSize {
        /// Standard page width (612pt)
        public static let width: CGFloat = 612

        /// Standard page height (792pt)
        public static let height: CGFloat = 792

        /// Effective content width (width - left margin - right margin)
        public static let contentWidth: CGFloat = width - Margin.left - Margin.right

        /// Effective content height (height - top margin - bottom margin)
        public static let contentHeight: CGFloat = height - Margin.top - Margin.bottom
    }
}
