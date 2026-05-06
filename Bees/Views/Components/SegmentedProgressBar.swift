import SwiftUI

struct SegmentedProgressBar: View {
    let total: Int
    let current: Int
    var color: Color = .white
    var trackOpacity: Double = 0.3

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i <= current ? color : color.opacity(trackOpacity))
                    .frame(height: 3)
                    .animation(.easeOut(duration: 0.3), value: current)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SegmentedProgressBar(total: 3, current: 0).padding()
        SegmentedProgressBar(total: 3, current: 1).padding()
        SegmentedProgressBar(total: 4, current: 2, color: .blue, trackOpacity: 0.2).padding()
    }
    .frame(width: 320)
    .background(.black)
}
