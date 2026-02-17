import Foundation

struct PortfolioData: Sendable {
    let tokens: [Token]
    let nftCollections: [NFTCollection]
}

@MainActor
@Observable
final class PortfolioViewModel {
    private let service: PortfolioServiceProtocol
    let address: String
    var state: ViewState<PortfolioData> = .loading

    init(address: String, service: PortfolioServiceProtocol) {
        self.address = address
        self.service = service
    }

    func load() async {
        state = .loading
        do {
            async let tokens = service.fetchTokenBalances(address: address)
            async let nfts = service.fetchNFTCollections(address: address)
            let result = try await PortfolioData(tokens: tokens, nftCollections: nfts)
            if result.tokens.isEmpty && result.nftCollections.isEmpty {
                state = .empty
            } else {
                state = .loaded(result)
            }
        } catch is CancellationError {
            return
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
