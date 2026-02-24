import SwiftUI

struct PortfolioView: View {
    @State private var viewModel: PortfolioViewModel
    var onSelectToken: (Token) -> Void

    init(address: String, service: PortfolioServiceProtocol, priceService: PriceServiceProtocol, onSelectToken: @escaping (Token) -> Void) {
        _viewModel = State(initialValue: PortfolioViewModel(address: address, service: service, priceService: priceService))
        self.onSelectToken = onSelectToken
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingView()
            case .loaded(let data):
                loadedContent(data)
            case .error(let message):
                ErrorStateView(message: message) {
                    Task { await viewModel.load() }
                }
            case .empty:
                EmptyStateView(
                    title: "No assets found",
                    subtitle: "This wallet doesn't hold any tokens or NFTs.",
                    systemImage: "tray"
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pfBackground)
        .navigationTitle("Portfolio")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
        .onDisappear {
            viewModel.stopPriceUpdates()
        }
    }

    @ViewBuilder
    private func loadedContent(_ data: PortfolioData) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PFSpacing.lg.rawValue) {
                if !data.tokens.isEmpty {
                    section(title: "Tokens") {
                        ForEach(data.tokens) { token in
                            Button {
                                onSelectToken(token)
                            } label: {
                                TokenRowView(token: token, price: viewModel.prices[token.id])
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !data.nftCollections.isEmpty {
                    section(title: "NFT Collections") {
                        ForEach(data.nftCollections) { collection in
                            NFTCollectionRowView(collection: collection)
                        }
                    }
                }
            }
            .padding(.horizontal, PFSpacing.lg.rawValue)
            .padding(.vertical, PFSpacing.md.rawValue)
        }
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: PFSpacing.sm.rawValue) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(Color.pfTextPrimary)
                .padding(.leading, PFSpacing.xs.rawValue)

            content()
        }
    }
}

#Preview {
    NavigationStack {
        PortfolioView(
            address: "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
            service: MockPortfolioService(),
            priceService: MockPriceService()
        ) { token in
            print("Selected: \(token.name)")
        }
    }
}
