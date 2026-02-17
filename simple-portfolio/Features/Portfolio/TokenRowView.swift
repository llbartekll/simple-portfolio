import SwiftUI

struct TokenRowView: View {
    let token: Token

    var body: some View {
        HStack(spacing: PFSpacing.md.rawValue) {
            AsyncImage(url: token.logoURL) { phase in
                switch phase {
                case .empty:
                    Circle()
                        .fill(Color.pfSurfaceRaised)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "circle.fill")
                        .foregroundStyle(Color.pfTextTertiary)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: PFSpacing.xs.rawValue) {
                Text(token.name)
                    .font(.headline)
                    .foregroundStyle(Color.pfTextPrimary)
                    .lineLimit(1)

                Text(token.symbol)
                    .font(.caption)
                    .foregroundStyle(Color.pfTextSecondary)
            }

            Spacer()

            Text(token.formattedBalance)
                .font(.body.monospacedDigit())
                .foregroundStyle(Color.pfTextPrimary)
        }
        .padding(PFSpacing.md.rawValue)
        .background(Color.pfSurface)
        .clipShape(RoundedRectangle(cornerRadius: PFRadius.md.rawValue, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(token.name), balance \(token.formattedBalance) \(token.symbol)")
    }
}

#Preview {
    VStack(spacing: PFSpacing.sm.rawValue) {
        ForEach(Token.mockList) { token in
            TokenRowView(token: token)
        }
    }
    .padding(PFSpacing.lg.rawValue)
    .background(Color.pfBackground)
}
