import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: PFSpacing.lg.rawValue) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: PFRadius.sm.rawValue, style: .continuous)
                    .fill(Color.pfSurfaceRaised)
                    .frame(height: 60)
                    .opacity(isAnimating ? 0.4 : 0.8)
                    .animation(
                        .easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: isAnimating
                    )
            }
        }
        .padding(.horizontal, PFSpacing.lg.rawValue)
        .task { isAnimating = true }
        .accessibilityLabel("Loading content")
    }
}

#Preview {
    LoadingView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pfBackground)
}
