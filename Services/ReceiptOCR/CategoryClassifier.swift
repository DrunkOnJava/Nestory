//
// Layer: Services
// Module: ReceiptOCR
// Purpose: Machine learning-based receipt category classification
//

import CoreML
import Foundation
import NaturalLanguage

// APPLE_FRAMEWORK_OPPORTUNITY: Replace with CreateML Framework - Train custom category classification models using CreateML for receipt-specific categorization

@MainActor
public final class CategoryClassifier: @unchecked Sendable {
    // MARK: - ML Model and Configuration

    private let nlModel: NLModel?
    private let embedding: NLEmbedding?
    private let categoryKeywords: [String: [String]]

    // Pre-defined category mappings with confidence weights
    private let vendorCategoryMap: [String: CategoryMatch]
    private let keywordCategoryMap: [String: CategoryMatch]

    public init() throws {
        // Initialize with pattern-based classification (ML model not available)
        self.nlModel = nil
        self.embedding = NLEmbedding.wordEmbedding(for: .english)

        // Initialize category keyword mappings
        self.categoryKeywords = Self.buildCategoryKeywords()
        self.vendorCategoryMap = Self.buildVendorCategoryMap()
        self.keywordCategoryMap = Self.buildKeywordCategoryMap()
    }

    // MARK: - Category Classification

    public func classify(vendor: String, items: [String], fullText: String) async throws -> [String] {
        var categoryConfidences: [String: Double] = [:]

        // Method 1: Vendor-based classification (highest confidence)
        if let vendorCategories = classifyByVendor(vendor) {
            for category in vendorCategories {
                categoryConfidences[category.category] = max(
                    categoryConfidences[category.category] ?? 0.0,
                    category.confidence * 0.8 // High weight for vendor classification
                )
            }
        }

        // Method 2: Item-based classification
        let itemCategories = classifyByItems(items)
        for category in itemCategories {
            categoryConfidences[category.category] = max(
                categoryConfidences[category.category] ?? 0.0,
                category.confidence * 0.6 // Medium weight for item classification
            )
        }

        // Method 3: Full text keyword analysis
        let textCategories = classifyByKeywords(fullText)
        for category in textCategories {
            categoryConfidences[category.category] = max(
                categoryConfidences[category.category] ?? 0.0,
                category.confidence * 0.4 // Lower weight for text classification
            )
        }

        // Method 4: Natural Language ML model (if available)
        if let mlCategories = try? await classifyWithMLModel(fullText) {
            for category in mlCategories {
                categoryConfidences[category.category] = max(
                    categoryConfidences[category.category] ?? 0.0,
                    category.confidence * 0.7 // High weight for ML classification
                )
            }
        }

        // Return categories with confidence above threshold
        let confidenceThreshold = 0.3
        return categoryConfidences
            .filter { $0.value >= confidenceThreshold }
            .sorted { $0.value > $1.value }
            .map(\.key)
    }

    // MARK: - Vendor-Based Classification

    private func classifyByVendor(_ vendor: String) -> [CategoryMatch]? {
        let normalizedVendor = vendor.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Direct vendor mapping
        for (vendorPattern, category) in vendorCategoryMap {
            if normalizedVendor.contains(vendorPattern.lowercased()) {
                return [category]
            }
        }

        // Pattern-based vendor classification
        return classifyVendorByPattern(normalizedVendor)
    }

    private func classifyVendorByPattern(_ vendor: String) -> [CategoryMatch]? {
        // Grocery stores
        if vendor.contains("market") || vendor.contains("food") || vendor.contains("grocer") {
            return [CategoryMatch(category: "Grocery", confidence: 0.85)]
        }

        // Hardware/Home improvement
        if vendor.contains("depot") || vendor.contains("hardware") || vendor.contains("supply") {
            return [CategoryMatch(category: "Home Improvement", confidence: 0.85)]
        }

        // Electronics
        if vendor.contains("electronic") || vendor.contains("tech") || vendor.contains("computer") {
            return [CategoryMatch(category: "Electronics", confidence: 0.85)]
        }

        // Pharmacy
        if vendor.contains("pharmacy") || vendor.contains("drug") || vendor.contains("rx") {
            return [CategoryMatch(category: "Health & Pharmacy", confidence: 0.85)]
        }

        return nil
    }

    // MARK: - Item-Based Classification

    private func classifyByItems(_ items: [String]) -> [CategoryMatch] {
        var categoryScores: [String: Double] = [:]

        for item in items {
            let itemCategories = classifyIndividualItem(item)
            for category in itemCategories {
                categoryScores[category.category] = (categoryScores[category.category] ?? 0.0) + category.confidence
            }
        }

        // Normalize scores by number of items
        let itemCount = max(items.count, 1)
        return categoryScores.map {
            CategoryMatch(category: $0.key, confidence: $0.value / Double(itemCount))
        }
    }

    private func classifyIndividualItem(_ item: String) -> [CategoryMatch] {
        let normalizedItem = item.lowercased()
        var matches: [CategoryMatch] = []

        for (category, keywords) in categoryKeywords {
            for keyword in keywords {
                if normalizedItem.contains(keyword.lowercased()) {
                    let confidence = calculateKeywordConfidence(keyword, in: normalizedItem)
                    matches.append(CategoryMatch(category: category, confidence: confidence))
                    break // Only match once per category per item
                }
            }
        }

        return matches
    }

    // MARK: - Keyword-Based Classification

    private func classifyByKeywords(_ text: String) -> [CategoryMatch] {
        let normalizedText = text.lowercased()
        var categoryScores: [String: Double] = [:]

        for (keyword, category) in keywordCategoryMap {
            let keywordCount = countOccurrences(of: keyword.lowercased(), in: normalizedText)
            if keywordCount > 0 {
                let score = Double(keywordCount) * category.confidence
                categoryScores[category.category] = (categoryScores[category.category] ?? 0.0) + score
            }
        }

        return categoryScores.map {
            CategoryMatch(category: $0.key, confidence: min($0.value, 1.0))
        }
    }

    // MARK: - ML Model Classification

    private func classifyWithMLModel(_: String) async throws -> [CategoryMatch]? {
        // APPLE_FRAMEWORK_OPPORTUNITY: Replace with Natural Language Framework - Use NLClassifier with custom trained model for receipt categorization
        // ML model classification is not available in this implementation
        // Use pattern-based classification as fallback
        nil
    }

    // MARK: - Helper Methods

    private func calculateKeywordConfidence(_ keyword: String, in text: String) -> Double {
        let keywordLength = keyword.count
        let textLength = text.count

        // Base confidence based on keyword specificity
        var confidence = 0.5

        // Longer keywords are more specific
        if keywordLength > 8 {
            confidence += 0.3
        } else if keywordLength > 5 {
            confidence += 0.2
        } else if keywordLength > 3 {
            confidence += 0.1
        }

        // Whole word matches are more confident
        if text.range(of: "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b", options: .regularExpression) != nil {
            confidence += 0.2
        }

        return min(confidence, 1.0)
    }

    private func countOccurrences(of keyword: String, in text: String) -> Int {
        text.components(separatedBy: keyword).count - 1
    }

    private static func parseMLPrediction(_ prediction: String) -> [CategoryMatch] {
        // Parse ML model output (assuming format like "category1:0.8,category2:0.6")
        let components = prediction.components(separatedBy: ",")
        var matches: [CategoryMatch] = []

        for component in components {
            let parts = component.components(separatedBy: ":")
            if parts.count == 2,
               let confidence = Double(parts[1].trimmingCharacters(in: .whitespaces))
            {
                let category = parts[0].trimmingCharacters(in: .whitespaces)
                matches.append(CategoryMatch(category: category, confidence: confidence))
            }
        }

        return matches
    }
}

// MARK: - Static Configuration

extension CategoryClassifier {
    private static func buildCategoryKeywords() -> [String: [String]] {
        [
            "Grocery": [
                "milk", "bread", "eggs", "cheese", "meat", "chicken", "beef", "pork",
                "apple", "banana", "orange", "vegetable", "fruit", "cereal", "pasta",
                "rice", "flour", "sugar", "salt", "pepper", "oil", "butter", "yogurt",
                "produce", "deli", "bakery", "frozen", "organic", "snack",
            ],
            "Electronics": [
                "phone", "computer", "laptop", "tablet", "camera", "headphone", "speaker",
                "charger", "cable", "battery", "memory", "storage", "processor", "monitor",
                "keyboard", "mouse", "gaming", "console", "television", "tv", "smart",
                "wireless", "bluetooth", "usb", "hdmi", "iphone", "android", "samsung",
            ],
            "Home Improvement": [
                "lumber", "wood", "nail", "screw", "hammer", "drill", "saw", "paint",
                "brush", "roller", "primer", "drywall", "insulation", "tile", "flooring",
                "plumbing", "electrical", "light", "fixture", "faucet", "pipe", "wire",
                "tool", "hardware", "garden", "lawn", "shed", "fence", "deck",
            ],
            "Clothing": [
                "shirt", "pants", "dress", "jacket", "coat", "shoes", "boots", "sneakers",
                "jeans", "sweater", "hoodie", "underwear", "socks", "hat", "cap", "belt",
                "accessory", "jewelry", "watch", "bag", "purse", "wallet", "clothing",
                "apparel", "fashion", "fabric", "cotton", "polyester", "size", "medium",
            ],
            "Health & Pharmacy": [
                "medicine", "prescription", "vitamin", "supplement", "bandage", "antiseptic",
                "thermometer", "blood pressure", "glucose", "insulin", "inhaler", "cream",
                "ointment", "pill", "tablet", "capsule", "liquid", "syrup", "health",
                "medical", "pharmacy", "drug", "rx", "otc", "first aid", "wellness",
            ],
            "Automotive": [
                "gas", "gasoline", "fuel", "oil", "brake", "tire", "battery", "engine",
                "transmission", "filter", "spark plug", "coolant", "antifreeze", "wiper",
                "car", "auto", "vehicle", "motor", "service", "repair", "maintenance",
                "part", "automotive", "garage", "mechanic", "inspection", "registration",
            ],
            "Office Supplies": [
                "pen", "pencil", "paper", "notebook", "folder", "binder", "stapler",
                "paperclip", "tape", "glue", "marker", "highlighter", "eraser", "ruler",
                "calculator", "printer", "ink", "toner", "envelope", "stamp", "label",
                "office", "supplies", "stationery", "filing", "organize", "desktop",
            ],
            "Entertainment": [
                "movie", "dvd", "blu-ray", "game", "book", "magazine", "music", "cd",
                "vinyl", "streaming", "subscription", "ticket", "concert", "theater",
                "sport", "hobby", "toy", "puzzle", "card", "board game", "entertainment",
                "leisure", "recreation", "fun", "activity", "event", "show",
            ],
        ]
    }

    private static func buildVendorCategoryMap() -> [String: CategoryMatch] {
        [
            // Grocery
            "walmart": CategoryMatch(category: "Grocery", confidence: 0.7),
            "target": CategoryMatch(category: "Grocery", confidence: 0.6),
            "kroger": CategoryMatch(category: "Grocery", confidence: 0.9),
            "safeway": CategoryMatch(category: "Grocery", confidence: 0.9),
            "whole foods": CategoryMatch(category: "Grocery", confidence: 0.9),
            "trader joe": CategoryMatch(category: "Grocery", confidence: 0.9),
            "costco": CategoryMatch(category: "Grocery", confidence: 0.8),

            // Electronics
            "best buy": CategoryMatch(category: "Electronics", confidence: 0.9),
            "apple store": CategoryMatch(category: "Electronics", confidence: 0.9),
            "microcenter": CategoryMatch(category: "Electronics", confidence: 0.9),
            "newegg": CategoryMatch(category: "Electronics", confidence: 0.9),

            // Home Improvement
            "home depot": CategoryMatch(category: "Home Improvement", confidence: 0.9),
            "lowes": CategoryMatch(category: "Home Improvement", confidence: 0.9),
            "ace hardware": CategoryMatch(category: "Home Improvement", confidence: 0.9),
            "menards": CategoryMatch(category: "Home Improvement", confidence: 0.9),

            // Health & Pharmacy
            "cvs": CategoryMatch(category: "Health & Pharmacy", confidence: 0.9),
            "walgreens": CategoryMatch(category: "Health & Pharmacy", confidence: 0.9),
            "rite aid": CategoryMatch(category: "Health & Pharmacy", confidence: 0.9),

            // Automotive
            "autozone": CategoryMatch(category: "Automotive", confidence: 0.9),
            "advance auto": CategoryMatch(category: "Automotive", confidence: 0.9),
            "napa": CategoryMatch(category: "Automotive", confidence: 0.9),
            "shell": CategoryMatch(category: "Automotive", confidence: 0.8),
            "exxon": CategoryMatch(category: "Automotive", confidence: 0.8),
            "bp": CategoryMatch(category: "Automotive", confidence: 0.8),

            // Office Supplies
            "staples": CategoryMatch(category: "Office Supplies", confidence: 0.9),
            "office depot": CategoryMatch(category: "Office Supplies", confidence: 0.9),
            "officemax": CategoryMatch(category: "Office Supplies", confidence: 0.9),
        ]
    }

    private static func buildKeywordCategoryMap() -> [String: CategoryMatch] {
        [
            "grocery": CategoryMatch(category: "Grocery", confidence: 0.8),
            "food": CategoryMatch(category: "Grocery", confidence: 0.6),
            "produce": CategoryMatch(category: "Grocery", confidence: 0.8),
            "electronics": CategoryMatch(category: "Electronics", confidence: 0.8),
            "computer": CategoryMatch(category: "Electronics", confidence: 0.7),
            "hardware": CategoryMatch(category: "Home Improvement", confidence: 0.7),
            "tools": CategoryMatch(category: "Home Improvement", confidence: 0.7),
            "pharmacy": CategoryMatch(category: "Health & Pharmacy", confidence: 0.9),
            "prescription": CategoryMatch(category: "Health & Pharmacy", confidence: 0.9),
            "automotive": CategoryMatch(category: "Automotive", confidence: 0.8),
            "gasoline": CategoryMatch(category: "Automotive", confidence: 0.9),
            "office": CategoryMatch(category: "Office Supplies", confidence: 0.7),
            "supplies": CategoryMatch(category: "Office Supplies", confidence: 0.5),
        ]
    }

    private static func createCategoryClassificationModel() throws -> MLModel {
        // Create a simple rule-based ML model for category classification
        // In a real implementation, this would load a trained Core ML model

        // For now, we'll create a placeholder model that can be replaced
        // with a trained model when available
        throw MLModelError.modelCreationFailed(underlying: "ML model not available in this implementation")
    }
}

// MARK: - Data Models

public struct CategoryMatch: Sendable {
    public let category: String
    public let confidence: Double

    public init(category: String, confidence: Double) {
        self.category = category
        self.confidence = confidence
    }
}

// MARK: - Error Types

public enum MLModelError: Error, LocalizedError, Sendable {
    case modelCreationFailed(underlying: String)
    case predictionFailed(underlying: String)

    public var errorDescription: String? {
        switch self {
        case let .modelCreationFailed(message):
            "Failed to create ML model: \(message)"
        case let .predictionFailed(message):
            "ML prediction failed: \(message)"
        }
    }
}
