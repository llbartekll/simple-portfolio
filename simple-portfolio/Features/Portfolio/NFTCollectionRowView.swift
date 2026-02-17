import SwiftUI

struct NFTCollectionRowView: View {
    let collection: NFTCollection

    var body: some View {
        HStack(spacing: PFSpacing.md.rawValue) {
            AsyncImage(url: collection.imageURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: PFRadius.sm.rawValue, style: .continuous)
                        .fill(Color.pfSurfaceRaised)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                        .foregroundStyle(Color.pfTextTertiary)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: PFRadius.sm.rawValue, style: .continuous))

            VStack(alignment: .leading, spacing: PFSpacing.xs.rawValue) {
                Text(collection.name)
                    .font(.headline)
                    .foregroundStyle(Color.pfTextPrimary)
                    .lineLimit(1)

                Text(collection.tokenType)
                    .font(.caption)
                    .foregroundStyle(Color.pfTextSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: PFSpacing.xs.rawValue) {
                Text("\(collection.ownedCount)")
                    .font(.caption.bold())
                    .foregroundStyle(Color.pfTextPrimary)
                    .padding(.horizontal, PFSpacing.sm.rawValue)
                    .padding(.vertical, PFSpacing.xs.rawValue)
                    .background(Color.pfSurfaceRaised)
                    .clipShape(Capsule())

                if let floorPrice = collection.formattedFloorPrice {
                    Text(floorPrice)
                        .font(.caption)
                        .foregroundStyle(Color.pfTextSecondary)
                }
            }
        }
        .padding(PFSpacing.md.rawValue)
        .background(Color.pfSurface)
        .clipShape(RoundedRectangle(cornerRadius: PFRadius.md.rawValue, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(collection.name), \(collection.ownedCount) owned")
    }
}

#Preview {
    VStack(spacing: PFSpacing.sm.rawValue) {
        ForEach(NFTCollection.mockList) { collection in
            NFTCollectionRowView(collection: collection)
        }
    }
    .padding(PFSpacing.lg.rawValue)
    .background(Color.pfBackground)
}
