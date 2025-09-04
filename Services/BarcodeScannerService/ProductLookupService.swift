//
// Layer: Services
// Module: BarcodeScannerService
// Purpose: Enhanced product lookup service with offline fallbacks and category suggestions
//

import Foundation
import os.log

/// Enhanced product lookup service for barcode scanning
public protocol ProductLookupService: Sendable {
    /// Look up product information from barcode with offline fallbacks
    func lookupProduct(barcode: String, type: String) async -> ProductInfo?

    /// Suggest category based on barcode prefix patterns
    func suggestCategory(from barcode: String, type: String) -> String?

    /// Get brand information from barcode prefix
    func extractBrandFromBarcode(_ barcode: String) -> String?

    /// Check if barcode is in known product database
    func isKnownProduct(barcode: String) -> Bool
}

@MainActor
public final class LiveProductLookupService: ProductLookupService, ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.drunkonjava.nestory", category: "ProductLookupService")
    private var cache: [String: (product: ProductInfo, timestamp: Date)] = [:]
    private let cacheTimeLimit: TimeInterval = 86400 // 24 hours

    public init() {}

    // MARK: - ProductLookupService Implementation

    public nonisolated func lookupProduct(barcode: String, type: String) async -> ProductInfo? {
        // Check cache first
        if let cachedEntry = await getCachedProduct(barcode: barcode) {
            return cachedEntry
        }

        // Try offline lookup first for known patterns
        if let offlineProduct = await offlineLookup(barcode: barcode, type: type) {
            await setCachedProduct(barcode: barcode, product: offlineProduct)
            return offlineProduct
        }

        // For production: Add API lookup here
        // let apiProduct = try? await apiLookup(barcode: barcode)

        return nil
    }

    public nonisolated func suggestCategory(from barcode: String, type _: String) -> String? {
        // Category suggestions based on barcode prefixes
        let categoryMappings: [String: String] = [
            // Technology & Electronics
            "00": "Electronics",
            "03": "Electronics",
            "04": "Electronics",
            "05": "Electronics",
            "06": "Electronics",
            "07": "Electronics",
            "08": "Books & Media",
            "09": "Books & Media",

            // Food & Beverages
            "1": "Food & Beverages",
            "2": "Food & Beverages",

            // Health & Beauty
            "3": "Health & Beauty",
            "30": "Health & Beauty",
            "31": "Health & Beauty",
            "32": "Health & Beauty",
            "33": "Health & Beauty",
            "34": "Health & Beauty",
            "35": "Health & Beauty",
            "36": "Health & Beauty",
            "37": "Health & Beauty",

            // Clothing & Accessories
            "4": "Clothing & Accessories",
            "40": "Clothing & Accessories",
            "41": "Clothing & Accessories",
            "42": "Clothing & Accessories",
            "43": "Clothing & Accessories",
            "44": "Clothing & Accessories",
            "45": "Clothing & Accessories",
            "46": "Clothing & Accessories",
            "47": "Clothing & Accessories",
            "48": "Clothing & Accessories",
            "49": "Clothing & Accessories",

            // Home & Garden
            "5": "Home & Garden",
            "50": "Home & Garden",
            "51": "Home & Garden",
            "52": "Home & Garden",
            "53": "Home & Garden",
            "54": "Home & Garden",
            "55": "Home & Garden",
            "56": "Home & Garden",
            "57": "Home & Garden",
            "58": "Home & Garden",
            "59": "Home & Garden",

            // Sports & Recreation
            "6": "Sports & Recreation",
            "60": "Sports & Recreation",
            "61": "Sports & Recreation",
            "62": "Sports & Recreation",
            "63": "Sports & Recreation",
            "64": "Sports & Recreation",
            "65": "Sports & Recreation",
            "66": "Sports & Recreation",
            "67": "Sports & Recreation",
            "68": "Sports & Recreation",
            "69": "Sports & Recreation",

            // Automotive & Tools
            "7": "Automotive & Tools",
            "70": "Automotive & Tools",
            "71": "Automotive & Tools",
            "72": "Automotive & Tools",
            "73": "Automotive & Tools",
            "74": "Automotive & Tools",
            "75": "Automotive & Tools",
            "76": "Automotive & Tools",
            "77": "Automotive & Tools",
            "78": "Automotive & Tools",
            "79": "Automotive & Tools",

            // Office & Stationery
            "8": "Office & Stationery",
            "80": "Office & Stationery",
            "81": "Office & Stationery",
            "82": "Office & Stationery",
            "83": "Office & Stationery",
            "84": "Office & Stationery",
            "85": "Office & Stationery",
            "86": "Office & Stationery",
            "87": "Office & Stationery",
            "88": "Office & Stationery",
            "89": "Office & Stationery",

            // General Merchandise
            "9": "General Merchandise",
            "90": "General Merchandise",
            "91": "General Merchandise",
            "92": "General Merchandise",
            "93": "General Merchandise",
            "94": "General Merchandise",
            "95": "General Merchandise",
            "96": "General Merchandise",
            "97": "General Merchandise",
            "98": "General Merchandise",
            "99": "General Merchandise",
        ]

        // Check for exact prefix matches first
        for length in [3, 2, 1] {
            if barcode.count >= length {
                let prefix = String(barcode.prefix(length))
                if let category = categoryMappings[prefix] {
                    return category
                }
            }
        }

        return nil
    }

    public nonisolated func extractBrandFromBarcode(_ barcode: String) -> String? {
        // Common brand prefixes in UPC/EAN codes
        let brandMappings: [String: String] = [
            // Technology brands
            "0012345": "Apple",
            "0885909": "Apple",
            "0190198": "Apple",
            "0190199": "Apple",
            "4547597": "Sony",
            "4901771": "Sony",
            "8806085": "Samsung",
            "8806086": "Samsung",
            "8801643": "Samsung",
            "3614720": "Microsoft",
            "0883929": "Microsoft",

            // Consumer goods
            "0037000": "Procter & Gamble",
            "0051000": "Campbell Soup",
            "0070847": "General Mills",
            "0016000": "General Mills",
            "0018000": "Kraft Heinz",
            "0021000": "Kraft Heinz",
            "0028400": "Kraft Heinz",
            "0043000": "Kellogg's",
            "0038000": "Kellogg's",

            // Retail brands
            "0078742": "Great Value (Walmart)",
            "0041220": "Kirkland (Costco)",
            "0365": "Whole Foods 365",
            "0049022": "Target Market Pantry",
        ]

        // Check for brand prefix matches
        for (prefix, brand) in brandMappings {
            if barcode.hasPrefix(prefix) {
                return brand
            }
        }

        return nil
    }

    public nonisolated func isKnownProduct(barcode: String) -> Bool {
        extractBrandFromBarcode(barcode) != nil ||
            knownProductDatabase.keys.contains { barcode.hasPrefix($0) }
    }

    // MARK: - Private Methods

    private nonisolated func offlineLookup(barcode: String, type: String) async -> ProductInfo? {
        // Check known product database
        for (prefix, productData) in knownProductDatabase {
            if barcode.hasPrefix(prefix) {
                var product = ProductInfo(
                    barcode: barcode,
                    title: productData.name,
                    brand: productData.brand,
                    category: productData.category,
                    price: productData.estimatedValue
                )

                // If brand not in database, try to extract from barcode
                if product.brand == nil {
                    product = ProductInfo(
                        barcode: barcode,
                        title: product.title,
                        brand: extractBrandFromBarcode(barcode),
                        category: product.category,
                        price: product.price
                    )
                }

                return product
            }
        }

        // Generate generic product info from barcode analysis
        if type.contains("EAN") || type.contains("UPC") {
            let suggestedCategory = suggestCategory(from: barcode, type: type)
            let extractedBrand = extractBrandFromBarcode(barcode)

            return ProductInfo(
                barcode: barcode,
                title: generateProductName(from: barcode, brand: extractedBrand, category: suggestedCategory),
                brand: extractedBrand,
                category: suggestedCategory
            )
        }

        return nil
    }

    private nonisolated func generateProductName(from barcode: String, brand: String?, category: String?) -> String {
        var components: [String] = []

        if let brand {
            components.append(brand)
        }

        if let category {
            components.append(category)
        } else {
            components.append("Product")
        }

        // Add barcode suffix for uniqueness
        let suffix = String(barcode.suffix(4))
        components.append("(\(suffix))")

        return components.joined(separator: " ")
    }

    // MARK: - Cache Management

    private func getCachedProduct(barcode: String) async -> ProductInfo? {
        await MainActor.run {
            if let entry = cache[barcode] {
                // Check if cache entry is still valid
                if Date().timeIntervalSince(entry.timestamp) < cacheTimeLimit {
                    return entry.product
                } else {
                    // Remove expired entry
                    cache.removeValue(forKey: barcode)
                    return nil
                }
            }
            return nil
        }
    }

    private func setCachedProduct(barcode: String, product: ProductInfo) async {
        await MainActor.run {
            cache[barcode] = (product: product, timestamp: Date())
        }
    }
}

// MARK: - Known Product Database

private let knownProductDatabase: [String: (name: String, brand: String?, model: String?, category: String?, estimatedValue: Double?)] = [
    // Apple Products (common prefixes)
    "0885909": (
        name: "iPhone",
        brand: "Apple",
        model: nil,
        category: "Electronics",
        estimatedValue: 800.0
    ),
    "0190198": (
        name: "iPad",
        brand: "Apple",
        model: nil,
        category: "Electronics",
        estimatedValue: 500.0
    ),
    "0190199": (
        name: "MacBook",
        brand: "Apple",
        model: nil,
        category: "Electronics",
        estimatedValue: 1200.0
    ),

    // Sony Products
    "4547597": (
        name: "PlayStation Console",
        brand: "Sony",
        model: nil,
        category: "Electronics",
        estimatedValue: 400.0
    ),

    // Samsung Products
    "8806085": (
        name: "Galaxy Smartphone",
        brand: "Samsung",
        model: nil,
        category: "Electronics",
        estimatedValue: 700.0
    ),

    // Microsoft Products
    "0883929": (
        name: "Xbox Console",
        brand: "Microsoft",
        model: nil,
        category: "Electronics",
        estimatedValue: 350.0
    ),

    // Common household items
    "0037000": (
        name: "Household Product",
        brand: "Procter & Gamble",
        model: nil,
        category: "Health & Beauty",
        estimatedValue: 10.0
    ),
    "0043000": (
        name: "Cereal",
        brand: "Kellogg's",
        model: nil,
        category: "Food & Beverages",
        estimatedValue: 5.0
    ),
    "0070847": (
        name: "Food Product",
        brand: "General Mills",
        model: nil,
        category: "Food & Beverages",
        estimatedValue: 8.0
    ),
]

// MARK: - Mock Implementation

public final class MockProductLookupService: ProductLookupService {
    public init() {}

    public func lookupProduct(barcode: String, type: String) async -> ProductInfo? {
        // Always return test data for mocking
        if type.contains("EAN") || type.contains("UPC") {
            return ProductInfo(
                barcode: barcode,
                title: "Mock Product",
                brand: "Mock Brand",
                category: "Electronics"
            )
        }
        return nil
    }

    public func suggestCategory(from _: String, type _: String) -> String? {
        "Electronics"
    }

    public func extractBrandFromBarcode(_: String) -> String? {
        "Mock Brand"
    }

    public func isKnownProduct(barcode _: String) -> Bool {
        true
    }
}
