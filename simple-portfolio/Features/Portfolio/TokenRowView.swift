import SwiftUI

struct TokenRowView: View {
    let token: Token
    var price: TokenPrice?

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

            VStack(alignment: .trailing, spacing: PFSpacing.xs.rawValue) {
                if let price {
                    Text(price.formattedUSD)
                        .font(.body.monospacedDigit())
                        .foregroundStyle(Color.pfTextPrimary)
                        .contentTransition(.numericText())
                } else {
                    Text("--")
                        .font(.body.monospacedDigit())
                        .foregroundStyle(Color.pfTextTertiary)
                }

                Text(token.formattedBalance)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(Color.pfTextSecondary)
            }
        }
        .padding(PFSpacing.md.rawValue)
        .background(Color.pfSurface)
        .clipShape(RoundedRectangle(cornerRadius: PFRadius.md.rawValue, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(priceAccessibilityLabel)
    }

    private var priceAccessibilityLabel: String {
        if let price {
            return "\(token.name), \(price.formattedUSD), balance \(token.formattedBalance) \(token.symbol)"
        }
        return "\(token.name), balance \(token.formattedBalance) \(token.symbol)"
    }
}

#Preview {
    VStack(spacing: PFSpacing.sm.rawValue) {
        ForEach(Token.mockList) { token in
            TokenRowView(token: token, price: MockPriceService.mockPrices[token.id])
        }
        TokenRowView(token: Token.mockList[0])
    }
    .padding(PFSpacing.lg.rawValue)
    .background(Color.pfBackground)
}
