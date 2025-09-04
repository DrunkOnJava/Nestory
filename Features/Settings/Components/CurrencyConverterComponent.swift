//
// Layer: Features
// Module: Settings/Components
// Purpose: Currency conversion settings and tools component
//

import SwiftUI
import Foundation

struct CurrencyConverterComponent: View {
    @State private var baseCurrency = "USD"
    @State private var displayCurrencies = Set(["USD", "EUR", "GBP"])
    @State private var autoUpdateRates = true
    @State private var lastUpdated = Date()
    @State private var showingConverter = false
    
    private let availableCurrencies = [
        ("USD", "US Dollar", "$"),
        ("EUR", "Euro", "€"),
        ("GBP", "British Pound", "£"),
        ("CAD", "Canadian Dollar", "C$"),
        ("JPY", "Japanese Yen", "¥"),
        ("AUD", "Australian Dollar", "A$"),
        ("CHF", "Swiss Franc", "CHF"),
        ("CNY", "Chinese Yuan", "¥"),
        ("INR", "Indian Rupee", "₹"),
        ("KRW", "South Korean Won", "₩")
    ]
    
    var body: some View {
        Section("Currency Settings") {
            Picker("Base Currency", selection: $baseCurrency) {
                ForEach(availableCurrencies, id: \.0) { code, name, symbol in
                    HStack {
                        Text(symbol)
                        Text("\(code) - \(name)")
                    }.tag(code)
                }
            }
            
            Toggle("Auto-update Exchange Rates", isOn: $autoUpdateRates)
            
            HStack {
                Text("Last Updated")
                Spacer()
                Text(lastUpdated.formatted(date: .abbreviated, time: .shortened))
                    .foregroundColor(.secondary)
            }
            
            Button("Update Rates Now") {
                updateExchangeRates()
            }
            .disabled(!autoUpdateRates)
        }
        
        Section("Display Currencies") {
            ForEach(availableCurrencies, id: \.0) { code, name, symbol in
                HStack {
                    Text("\(symbol) \(code)")
                    Text(name)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if displayCurrencies.contains(code) {
                        Button("Remove") {
                            displayCurrencies.remove(code)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .controlSize(.small)
                    } else {
                        Button("Add") {
                            displayCurrencies.insert(code)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.small)
                    }
                }
            }
        }
        
        Section("Tools") {
            Button("Currency Converter") {
                showingConverter = true
            }
            
            NavigationLink("Exchange Rate History") {
                ExchangeRateHistoryView()
            }
            
            NavigationLink("Multi-Currency Report") {
                MultiCurrencyReportView()
            }
        }
        .sheet(isPresented: $showingConverter) {
            CurrencyConverterView(baseCurrency: baseCurrency)
        }
    }
    
    private func updateExchangeRates() {
        // Update exchange rates from API
        lastUpdated = Date()
    }
}

private struct CurrencyConverterView: View {
    let baseCurrency: String
    @State private var amount = ""
    @State private var fromCurrency = "USD"
    @State private var toCurrency = "EUR"
    @State private var convertedAmount = 0.0
    @State private var exchangeRate = 1.0
    @Environment(\.dismiss) private var dismiss
    
    private let currencies = [
        ("USD", "$"), ("EUR", "€"), ("GBP", "£"), ("CAD", "C$"),
        ("JPY", "¥"), ("AUD", "A$"), ("CHF", "CHF"), ("CNY", "¥")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Currency Converter")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    // From Currency
                    VStack(alignment: .leading, spacing: 8) {
                        Text("From")
                            .font(.headline)
                        
                        HStack {
                            Picker("From Currency", selection: $fromCurrency) {
                                ForEach(currencies, id: \.0) { code, symbol in
                                    Text("\(symbol) \(code)").tag(code)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            TextField("Amount", text: $amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: amount) { _, _ in convertCurrency() }
                        }
                    }
                    
                    // Swap Button
                    Button(action: swapCurrencies) {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    
                    // To Currency
                    VStack(alignment: .leading, spacing: 8) {
                        Text("To")
                            .font(.headline)
                        
                        HStack {
                            Picker("To Currency", selection: $toCurrency) {
                                ForEach(currencies, id: \.0) { code, symbol in
                                    Text("\(symbol) \(code)").tag(code)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            Text(String(format: "%.2f", convertedAmount))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    
                    // Exchange Rate Info
                    VStack(spacing: 4) {
                        Text("Exchange Rate")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("1 \(fromCurrency) = \(String(format: "%.4f", exchangeRate)) \(toCurrency)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Quick Amount Buttons
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach([10, 50, 100, 500, 1000, 5000], id: \.self) { value in
                        Button("\(value)") {
                            amount = String(value)
                            convertCurrency()
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onChange(of: fromCurrency) { _, _ in convertCurrency() }
            .onChange(of: toCurrency) { _, _ in convertCurrency() }
            .onAppear {
                fromCurrency = baseCurrency
                convertCurrency()
            }
        }
    }
    
    private func convertCurrency() {
        guard let inputAmount = Double(amount) else {
            convertedAmount = 0.0
            return
        }
        
        // Mock exchange rates - in real app, fetch from API
        let rates = [
            "USD": ["EUR": 0.85, "GBP": 0.73, "CAD": 1.25, "JPY": 110.0],
            "EUR": ["USD": 1.18, "GBP": 0.86, "CAD": 1.47, "JPY": 129.0],
            "GBP": ["USD": 1.37, "EUR": 1.16, "CAD": 1.71, "JPY": 150.0]
        ]
        
        if fromCurrency == toCurrency {
            exchangeRate = 1.0
            convertedAmount = inputAmount
        } else if let fromRates = rates[fromCurrency], let rate = fromRates[toCurrency] {
            exchangeRate = rate
            convertedAmount = inputAmount * rate
        } else {
            // Fallback calculation through USD
            exchangeRate = 1.0
            convertedAmount = inputAmount
        }
    }
    
    private func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
        convertCurrency()
    }
}

private struct ExchangeRateHistoryView: View {
    @State private var selectedPair = "USD/EUR"
    @State private var timeframe = TimeFrame.month
    
    private let currencyPairs = ["USD/EUR", "USD/GBP", "USD/JPY", "EUR/GBP"]
    
    var body: some View {
        VStack(spacing: 16) {
            Picker("Currency Pair", selection: $selectedPair) {
                ForEach(currencyPairs, id: \.self) { pair in
                    Text(pair).tag(pair)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("Timeframe", selection: $timeframe) {
                ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                    Text(timeframe.displayName).tag(timeframe)
                }
            }
            .pickerStyle(.segmented)
            
            // Mock chart placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Exchange Rate Chart")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(selectedPair)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                )
            
            // Rate Statistics
            VStack(spacing: 12) {
                StatRow(label: "Current Rate", value: "0.8457")
                StatRow(label: "24h Change", value: "+0.0023 (+0.27%)", isPositive: true)
                StatRow(label: "High", value: "0.8480")
                StatRow(label: "Low", value: "0.8431")
                StatRow(label: "Average", value: "0.8456")
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Spacer()
        }
        .padding()
        .navigationTitle("Exchange Rate History")
    }
}

private struct MultiCurrencyReportView: View {
    @State private var totalValue = 2500.0
    @State private var selectedCurrencies = ["USD", "EUR", "GBP", "JPY"]
    
    var body: some View {
        List {
            Section("Total Inventory Value") {
                ForEach(selectedCurrencies, id: \.self) { currency in
                    HStack {
                        Text(currencySymbol(for: currency))
                            .font(.headline)
                        Text(currency)
                        
                        Spacer()
                        
                        Text(formatCurrency(totalValue, currency: currency))
                            .font(.headline)
                    }
                }
            }
            
            Section("Value by Category") {
                CategoryValueRow(category: "Electronics", usdValue: 1200.0, currencies: selectedCurrencies)
                CategoryValueRow(category: "Furniture", usdValue: 800.0, currencies: selectedCurrencies)
                CategoryValueRow(category: "Jewelry", usdValue: 500.0, currencies: selectedCurrencies)
            }
            
            Section("Actions") {
                Button("Export Multi-Currency Report") {
                    // Export report
                }
                
                Button("Share Report") {
                    // Share functionality
                }
            }
        }
        .navigationTitle("Multi-Currency Report")
    }
    
    private func currencySymbol(for code: String) -> String {
        switch code {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "JPY": return "¥"
        case "CAD": return "C$"
        case "AUD": return "A$"
        default: return code
        }
    }
    
    private func formatCurrency(_ amount: Double, currency: String) -> String {
        // Mock conversion rates
        let rates = ["USD": 1.0, "EUR": 0.85, "GBP": 0.73, "JPY": 110.0]
        let convertedAmount = amount * (rates[currency] ?? 1.0)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        
        return formatter.string(from: NSNumber(value: convertedAmount)) ?? "\(convertedAmount)"
    }
}

private struct StatRow: View {
    let label: String
    let value: String
    var isPositive: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(isPositive ? .green : .primary)
        }
    }
}

private struct CategoryValueRow: View {
    let category: String
    let usdValue: Double
    let currencies: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(category)
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 4) {
                ForEach(currencies.prefix(4), id: \.self) { currency in
                    HStack {
                        Text(currency)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatValue(usdValue, currency: currency))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    private func formatValue(_ amount: Double, currency: String) -> String {
        let rates = ["USD": 1.0, "EUR": 0.85, "GBP": 0.73, "JPY": 110.0]
        let convertedAmount = amount * (rates[currency] ?? 1.0)
        return String(format: "%.0f", convertedAmount)
    }
}

private enum TimeFrame: CaseIterable {
    case day, week, month, year
    
    var displayName: String {
        switch self {
        case .day: return "1D"
        case .week: return "1W"
        case .month: return "1M"
        case .year: return "1Y"
        }
    }
}

#Preview {
    NavigationView {
        List {
            CurrencyConverterComponent()
        }
        .navigationTitle("Settings")
    }
}