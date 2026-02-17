import SwiftUI

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(spacing: PFSpacing.lg.rawValue) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(Color.pfTextTertiary)

            Text(title)
                .font(.title2.bold())
                .foregroundStyle(Color.pfTextPrimary)

            Text(subtitle)
                .font(.body)
                .foregroundStyle(Color.pfTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(PFSpacing.lg.rawValue)
    }
}

#Preview {
    EmptyStateView(
        title: "No tokens found",
        subtitle: "This wallet doesn't hold any tokens yet.",
        systemImage: "tray"
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.pfBackground)
}
