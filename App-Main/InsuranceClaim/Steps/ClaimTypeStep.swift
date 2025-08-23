//
// Layer: App-Main
// Module: InsuranceClaim/Steps
// Purpose: Claim type selection step with insurance company picker
//

import SwiftUI

public struct ClaimTypeStep: View {
    @Binding public var selectedClaimType: ClaimType
    @Binding public var selectedCompany: InsuranceCompany
    
    public init(
        selectedClaimType: Binding<ClaimType>,
        selectedCompany: Binding<InsuranceCompany>
    ) {
        self._selectedClaimType = selectedClaimType
        self._selectedCompany = selectedCompany
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Step 1: Claim Type")
                .font(.title2)
                .fontWeight(.bold)

            Text("What type of incident occurred?")
                .foregroundColor(.secondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 16) {
                ForEach(ClaimType.allCases, id: \.self) { claimType in
                    ClaimTypeCard(
                        claimType: claimType,
                        isSelected: selectedClaimType == claimType
                    ) {
                        selectedClaimType = claimType
                    }
                }
            }

            Text("Insurance Company")
                .font(.headline)
                .padding(.top)

            Picker("Insurance Company", selection: $selectedCompany) {
                ForEach(InsuranceCompany.allCases, id: \.self) { company in
                    Text(company.rawValue).tag(company)
                }
            }
            .pickerStyle(.menu)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

#Preview {
    ClaimTypeStep(
        selectedClaimType: .constant(.generalLoss),
        selectedCompany: .constant(.aaa)
    )
    .padding()
}