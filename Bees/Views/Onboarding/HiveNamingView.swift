import SwiftUI

struct HiveNamingView: View {
    @Binding var hiveName: String
    var onContinue: () -> Void

    private let suggestions = ["Buzzy McHive", "Honeycomb HQ", "The Hive Mind", "Bee Yoncé"]
    private let nameLimit = 24

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BeesSpacing.l) {
                Text("Name your hive")
                    .font(BeesType.displayL)
                    .foregroundStyle(BeesColors.charcoal900)
                    .padding(.top, BeesSpacing.l)

                VStack(alignment: .leading, spacing: BeesSpacing.xs) {
                    TextField("Buzzy McHive", text: $hiveName)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: hiveName) { _, newValue in
                            if newValue.count > nameLimit {
                                hiveName = String(newValue.prefix(nameLimit))
                            }
                        }
                    Text("Up to \(nameLimit) characters · \(hiveName.count)/\(nameLimit)")
                        .font(BeesType.captionS)
                        .foregroundStyle(BeesColors.charcoal600)
                }

                VStack(alignment: .leading, spacing: BeesSpacing.s) {
                    SectionHeader(title: "Stuck? Try one of these")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BeesSpacing.s) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button {
                                hiveName = suggestion
                            } label: {
                                Text(suggestion)
                                    .font(BeesType.bodyM)
                                    .foregroundStyle(BeesColors.charcoal900)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, BeesSpacing.s)
                                    .background(.white, in: RoundedRectangle(cornerRadius: BeesRadius.md))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Text("Or use the default: Hive #47")
                    .font(BeesType.bodyM)
                    .foregroundStyle(BeesColors.charcoal600)
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.bottom, BeesSpacing.xl)
        }
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            Button("Continue") {
                if hiveName.isEmpty { hiveName = "Hive #47" }
                onContinue()
            }
            .buttonStyle(.beesPrimary)
            .padding(.horizontal, BeesSpacing.m)
            .padding(.vertical, BeesSpacing.s)
            .background(.regularMaterial)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        HiveNamingView(hiveName: .constant(""), onContinue: {})
    }
}
