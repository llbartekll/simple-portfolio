import SwiftUI

struct ErrorStateView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: PFSpacing.lg.rawValue) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.pfNegative)

            Text("Something went wrong")
                .font(.title2.bold())
                .foregroundStyle(Color.pfTextPrimary)

            Text(message)
                .font(.body)
                .foregroundStyle(Color.pfTextSecondary)
                .multilineTextAlignment(.center)

            Button(action: retryAction) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundStyle(Color.pfTextPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PFSpacing.md.rawValue)
                    .background(Color.pfAccent)
                    .clipShape(RoundedRectangle(cornerRadius: PFRadius.md.rawValue, style: .continuous))
            }
            .accessibilityLabel("Retry loading")
            .padding(.horizontal, PFSpacing.xxl.rawValue)
        }
        .padding(PFSpacing.lg.rawValue)
    }
}

#Preview {
    ErrorStateView(message: "Network request failed. Please try again.") {}
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pfBackground)
}
