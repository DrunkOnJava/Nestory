//
// Layer: App-Main
// Module: SettingsViews
// Purpose: Currency management and conversion settings
//

import SwiftUI
import Foundation

// App layer - no direct logging imports

struct CurrencySettingsView: View {
    @State private var currencyService: LiveCurrencyService?
    @State private var supportedCurrencies: [Currency] = []
    @State private var selectedCurrency: Currency?
    @State private var defaultCurrency = "USD"
    @State private var showCurrencyPicker = false
    @State private var showingCurrencyConverter = false
    @State private var isUpdatingRates = false
    @State private var lastUpdateDate: Date?
    @State private var errorMessage: String?

    // Converter state
    @State private var fromAmount = ""
    @State private var fromCurrency = "USD"
    @State private var toCurrency = "EUR"
    @State private var convertedAmount: Decimal?

    var body: some View {
        Section("Currency Settings") {
            // Default Currency Selection
            HStack {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(.green)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Default Currency")
                        .font(.headline)
                    Text("Used for new items and reports")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { showCurrencyPicker = true }) {
                    HStack {
                        if let currency = supportedCurrencies.first(where: { $0.code == defaultCurrency }) {
                            Text("\(currency.symbol) \(currency.code)")
                                .foregroundColor(.primary)
                        } else {
                            Text(defaultCurrency)
                                .foregroundColor(.primary)
                        }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)

            // Currency Converter
            Button(action: { showingCurrencyConverter = true }) {
                HStack {
                    Image(systemName: "arrow.left.arrow.right.circle")
                        .foregroundColor(.blue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Currency Converter")
                            .foregroundColor(.primary)
                        Text("Convert between supported currencies")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)

            // Update Exchange Rates
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Exchange Rates")
                    if let lastUpdate = lastUpdateDate {
                        Text("Updated \(lastUpdate, style: .relative) ago")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Using offline rates")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if isUpdatingRates {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Button("Update") {
                        updateExchangeRates()
                    }
                    .disabled(isUpdatingRates)
                }
            }
            .padding(.vertical, 4)

            // Show error if any
            if let error = errorMessage {
                Label(error, systemImage: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
        }
        .sheet(isPresented: $showCurrencyPicker) {
            NavigationStack {
                List(supportedCurrencies) { currency in
                    Button(action: {
                        defaultCurrency = currency.code
                        showCurrencyPicker = false
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(currency.symbol) \(currency.code)")
                                    .font(.headline)
                                Text(currency.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if currency.code == defaultCurrency {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }
                .navigationTitle("Select Currency")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showCurrencyPicker = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingCurrencyConverter) {
            NavigationStack {
                Form {
                    Section("Convert Currency") {
                        // From Amount and Currency
                        HStack {
                            TextField("Amount", text: $fromAmount)
                                .keyboardType(.decimalPad)
                                .frame(maxWidth: 100)

                            Picker("From", selection: $fromCurrency) {
                                ForEach(supportedCurrencies) { currency in
                                    Text("\(currency.symbol) \(currency.code)")
                                        .tag(currency.code)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        // To Currency
                        HStack {
                            Text("to")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: 100, alignment: .trailing)

                            Picker("To", selection: $toCurrency) {
                                ForEach(supportedCurrencies) { currency in
                                    Text("\(currency.symbol) \(currency.code)")
                                        .tag(currency.code)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        // Result
                        if let converted = convertedAmount,
                           let toCurrencyInfo = supportedCurrencies.first(where: { $0.code == toCurrency })
                        {
                            HStack {
                                Text("Result")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(toCurrencyInfo.symbol)\(converted, format: .number.precision(.fractionLength(0 ... toCurrencyInfo.decimals)))")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }

                        // Convert Button
                        Button("Convert") {
                            performConversion()
                        }
                        .disabled(fromAmount.isEmpty || isUpdatingRates)
                        .buttonStyle(.borderedProminent)
                    }
                }
                .navigationTitle("Currency Converter")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingCurrencyConverter = false
                        }
                    }
                }
            }
        }
        .onAppear {
            setupCurrencyService()
        }
    }

    private func setupCurrencyService() {
        do {
            currencyService = try LiveCurrencyService()
            Task {
                supportedCurrencies = await currencyService?.getSupportedCurrencies() ?? []
            }
        } catch {
            errorMessage = "Failed to initialize currency service"
        }
    }

    private func updateExchangeRates() {
        guard let service = currencyService else { return }

        isUpdatingRates = true
        errorMessage = nil

        Task {
            do {
                try await service.updateRates()
                await MainActor.run {
                    lastUpdateDate = Date()
                    isUpdatingRates = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to update rates: \(error.localizedDescription)"
                    isUpdatingRates = false
                }
            }
        }
    }

    private func performConversion() {
        guard let service = currencyService,
              let amount = Decimal(string: fromAmount),
              amount > 0
        else {
            return
        }

        Task {
            do {
                let result = try await service.convert(
                    amount: amount,
                    from: fromCurrency,
                    to: toCurrency
                )
                await MainActor.run {
                    convertedAmount = result
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Conversion failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    Form {
        CurrencySettingsView()
    }
}
