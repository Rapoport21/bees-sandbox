import SwiftUI

struct SectionHeader: View {
    let title: String
    var trailing: String?

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(BeesType.captionM)
                .tracking(1)
                .foregroundStyle(BeesColors.charcoal600)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.charcoal600)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SectionHeader(title: "Base design", trailing: "1 of 8")
        SectionHeader(title: "Custom text")
    }
    .padding()
}
