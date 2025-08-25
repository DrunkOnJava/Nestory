//
// Layer: App-Main
// Module: WarrantyViews/WarrantyTracking/Sheets/ManualForm
// Purpose: Coverage period input section with validation
//

import SwiftUI

public struct CoveragePeriodSection: View {
    @Binding public var startDate: Date
    @Binding public var endDate: Date
    
    public init(
        startDate: Binding<Date>,
        endDate: Binding<Date>
    ) {
        self._startDate = startDate
        self._endDate = endDate
    }
    
    public var body: some View {
        Section(header: Text("Coverage Period")) {
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
            
            if endDate <= startDate {
                Label("End date must be after start date", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    Form {
        CoveragePeriodSection(
            startDate: .constant(Date()),
            endDate: .constant(Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date())
        )
    }
}