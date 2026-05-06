import SwiftUI

struct FarmTabView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BeesSpacing.l) {
                    RoundedRectangle(cornerRadius: BeesRadius.lg)
                        .fill(LinearGradient(
                            colors: [BeesColors.honey300, BeesColors.honey500],
                            startPoint: .top, endPoint: .bottom))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(.white.opacity(0.4))
                        )

                    VStack(alignment: .leading, spacing: BeesSpacing.xs) {
                        Text(Fixtures.demoFarm.name)
                            .font(BeesType.displayL)
                        Text(Fixtures.demoFarm.location)
                            .font(BeesType.bodyM)
                            .foregroundStyle(BeesColors.charcoal600)
                    }

                    VStack(alignment: .leading, spacing: BeesSpacing.xs) {
                        Text("YOUR FARMER")
                            .font(BeesType.captionM)
                            .tracking(1)
                            .foregroundStyle(BeesColors.charcoal600)
                        Text(Fixtures.demoFarm.farmerName)
                            .font(BeesType.headingM)
                        Text(Fixtures.demoFarm.farmerBio)
                            .font(BeesType.bodyM)
                            .foregroundStyle(BeesColors.charcoal600)
                    }

                    VStack(alignment: .leading, spacing: BeesSpacing.xs) {
                        Text("ABOUT THE FARM")
                            .font(BeesType.captionM)
                            .tracking(1)
                            .foregroundStyle(BeesColors.charcoal600)
                        Text(Fixtures.demoFarm.story)
                            .font(BeesType.bodyL)
                    }
                }
                .padding(BeesSpacing.m)
            }
            .navigationTitle("Farm")
        }
    }
}

#Preview {
    FarmTabView()
}
