// Layer: Foundation

import Foundation

public enum Validation {
    public static func validateEmail(_ email: String) throws {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        guard predicate.evaluate(with: email) else {
            throw AppError.validation(field: "email", reason: "Invalid email format")
        }
    }

    public static func validatePhoneNumber(_ phone: String) throws {
        let phoneRegex = #"^[\+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,9}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)

        guard predicate.evaluate(with: phone) else {
            throw AppError.validation(field: "phone", reason: "Invalid phone number format")
        }
    }

    public static func validateURL(_ urlString: String) throws {
        guard let url = URL(string: urlString),
              url.scheme != nil,
              url.host != nil
        else {
            throw AppError.validation(field: "url", reason: "Invalid URL format")
        }
    }

    public static func validateLength(
        _ string: String,
        field: String,
        min: Int? = nil,
        max: Int? = nil
    ) throws {
        if let min, string.count < min {
            throw AppError.validation(field: field, reason: "Must be at least \(min) characters")
        }

        if let max, string.count > max {
            throw AppError.validation(field: field, reason: "Must be at most \(max) characters")
        }
    }

    public static func validateRange<T: Comparable>(
        _ value: T,
        field: String,
        min: T? = nil,
        max: T? = nil
    ) throws {
        if let min, value < min {
            throw AppError.validation(field: field, reason: "Must be at least \(min)")
        }

        if let max, value > max {
            throw AppError.validation(field: field, reason: "Must be at most \(max)")
        }
    }

    public static func validateNotEmpty(_ string: String, field: String) throws {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AppError.validation(field: field, reason: "Cannot be empty")
        }
    }

    public static func validateAlphanumeric(_ string: String, field: String) throws {
        let alphanumericRegex = "^[a-zA-Z0-9]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", alphanumericRegex)

        guard predicate.evaluate(with: string) else {
            throw AppError.validation(field: field, reason: "Must contain only letters and numbers")
        }
    }

    public static func validateHexColor(_ color: String) throws {
        let hexRegex = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", hexRegex)

        guard predicate.evaluate(with: color) else {
            throw AppError.validation(field: "color", reason: "Invalid hex color format")
        }
    }

    public static func validateSerialNumber(_ serial: String) throws {
        let serialRegex = "^[A-Z0-9\\-]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", serialRegex)

        guard predicate.evaluate(with: serial.uppercased()) else {
            throw AppError.validation(field: "serialNumber", reason: "Invalid serial number format")
        }
    }

    public static func validateBarcode(_ barcode: String) throws {
        let barcodeRegex = "^[0-9]{8,13}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", barcodeRegex)

        guard predicate.evaluate(with: barcode) else {
            throw AppError.validation(field: "barcode", reason: "Invalid barcode format")
        }
    }

    public static func validateUUID(_ uuidString: String) throws {
        guard UUID(uuidString: uuidString) != nil else {
            throw AppError.validation(field: "uuid", reason: "Invalid UUID format")
        }
    }

    public static func validateFutureDate(_ date: Date, field: String) throws {
        guard date > Date() else {
            throw AppError.validation(field: field, reason: "Date must be in the future")
        }
    }

    public static func validatePastDate(_ date: Date, field: String) throws {
        guard date < Date() else {
            throw AppError.validation(field: field, reason: "Date must be in the past")
        }
    }

    public static func validateDateRange(
        start: Date,
        end: Date,
        startField: String = "startDate",
        endField: String = "endDate"
    ) throws {
        guard start < end else {
            throw AppError.validation(
                field: "\(startField)-\(endField)",
                reason: "Start date must be before end date"
            )
        }
    }

    public static func validatePositive(
        _ value: some Numeric & Comparable & ExpressibleByIntegerLiteral,
        field: String
    ) throws {
        guard value > 0 else {
            throw AppError.validation(field: field, reason: "Must be positive")
        }
    }

    public static func validateNonNegative(
        _ value: some Numeric & Comparable & ExpressibleByIntegerLiteral,
        field: String
    ) throws {
        guard value >= 0 else {
            throw AppError.validation(field: field, reason: "Cannot be negative")
        }
    }
}
