import SwiftUI

struct HoneyTabView: View {
    var body: some View {
        HoneyHomeView()
    }
}

#Preview {
    HoneyTabView()
        .environment(ServiceContainer.preview())
}
