import SwiftUI

struct HoneyTabView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("Honey", systemImage: "drop.fill")
            } description: {
                Text("Sticker customizer, shipment tracking, and gift flow ship next.")
            }
            .navigationTitle("Honey")
        }
    }
}

#Preview {
    HoneyTabView()
}
