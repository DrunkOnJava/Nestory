import Foundation

enum Secrets {
    static let cloudKitContainer =
        ProcessInfo.processInfo.environment["CLOUDKIT_CONTAINER"] ?? "iCloud.com.nestory.app"
    static let fxAPIKey =
        ProcessInfo.processInfo.environment["FX_API_KEY"] ?? "DEMO_KEY"
    static let barcodeAPIKey =
        ProcessInfo.processInfo.environment["BARCODE_API_KEY"]
    static let ocrServiceKey =
        ProcessInfo.processInfo.environment["OCR_SERVICE_KEY"]
}

EOF < /dev/null
