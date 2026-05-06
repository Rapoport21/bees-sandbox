import SwiftUI

struct BillingHistoryView: View {
    @Environment(ServiceContainer.self) private var services

    var body: some View {
        List {
            ForEach(services.billingHistory) { record in
                NavigationLink(value: record) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(record.date, format: .dateTime.day().month(.abbreviated).year())
                                .font(BeesType.bodyM)
                                .foregroundStyle(BeesColors.charcoal900)
                            Text(record.tier.displayName)
                                .font(BeesType.captionM)
                                .foregroundStyle(BeesColors.charcoal600)
                        }
                        Spacer()
                        Text("$\(format(record.amount))")
                            .font(BeesType.monoM)
                            .foregroundStyle(BeesColors.charcoal900)
                    }
                }
            }
        }
        .navigationDestination(for: BillingRecord.self) { record in
            BillingDetailView(record: record)
        }
        .navigationTitle("Billing history")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func format(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }
}

struct BillingDetailView: View {
    let record: BillingRecord

    var body: some View {
        List {
            Section {
                row("Date", value: record.date.formatted(.dateTime.day().month(.wide).year()))
                row("Tier", value: record.tier.displayName)
                row("Status", value: record.status.displayName)
                row("Amount", value: "$\(format(record.amount))")
            }
            Section {
                Button {
                } label: {
                    Label("Download receipt", systemImage: "arrow.down.doc.fill")
                }
            }
        }
        .navigationTitle("Receipt")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(BeesColors.charcoal600)
            Spacer()
            Text(value).foregroundStyle(BeesColors.charcoal900)
        }
    }

    private func format(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }
}

#Preview {
    NavigationStack {
        BillingHistoryView()
    }
    .environment(ServiceContainer.preview())
}
