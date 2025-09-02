//
// Layer: Features
// Module: Settings/Components
// Purpose: Currency converter component for Settings feature
//

import SwiftUI
import Foundation

struct CurrencyConverterComponent {
    
    @MainActor
    static func currencyConverterView() -> some View {
        VStack(spacing: 20) {
            Text("Currency Converter")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Convert between different currencies for accurate item valuations.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                HStack {
                    TextField("Amount", text: .constant("100"))
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    
                    Picker("From", selection: .constant("USD")) {
                        Text("USD").tag("USD")
                        Text("EUR").tag("EUR")
                        Text("GBP").tag("GBP")
                    }
                    .pickerStyle(.menu)
                }
                
                Image(systemName: "arrow.down")
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("85.32")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Picker("To", selection: .constant("EUR")) {
                        Text("USD").tag("USD")
                        Text("EUR").tag("EUR") 
                        Text("GBP").tag("GBP")
                    }
                    .pickerStyle(.menu)
                }
            }
            
            Text("Rates updated daily")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Currency Converter")
    }
}