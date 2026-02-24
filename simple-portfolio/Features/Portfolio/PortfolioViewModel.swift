import Foundation
import os

private let logger = Logger(subsystem: "com.soberkit.simple-portfolio", category: "PortfolioViewModel")

struct PortfolioData: Sendable {
    let tokens: [Token]
    let nftCollections: [NFTCollection]
}

@MainActor
@Observable
final class PortfolioViewModel {
    private let service: PortfolioServiceProtocol
    private let priceService: PriceServiceProtocol
    let address: String
    var state: ViewState<PortfolioData> = .loading
    var prices: [String: TokenPrice] = [:]
    private var priceTask: Task<Void, Never>?

    init(address: String, service: PortfolioServiceProtocol, priceService: PriceServiceProtocol) {
        self.address = address
        self.service = service
        self.priceService = priceService
    }

    func load() async {
        stopPriceUpdates()
        state = .loading
        do {
            async let tokens = service.fetchTokenBalances(address: address)
            async let nfts = service.fetchNFTCollections(address: address)
            let result = try await PortfolioData(tokens: tokens, nftCollections: nfts)
            if result.tokens.isEmpty && result.nftCollections.isEmpty {
                state = .empty
            } else {
                state = .loaded(result)
                logger.info("Loaded \(result.tokens.count) tokens, starting price updates")
                for token in result.tokens {
                    logger.info("  token.id=\(token.id), network=\(token.network), address=\(token.tokenAddress)")
                }
                startPriceUpdates(for: result.tokens)
            }
        } catch is CancellationError {
            return
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func stopPriceUpdates() {
        priceTask?.cancel()
        priceTask = nil
        priceService.disconnect()
        prices = [:]
    }

    private func startPriceUpdates(for tokens: [Token]) {
        let stream = priceService.priceUpdates(for: tokens)
        priceTask = Task {
            for await snapshot in stream {
                guard !Task.isCancelled else { break }
                logger.info("VM received price snapshot with \(snapshot.count) entries")
                self.prices = snapshot
            }
            logger.info("Price stream ended")
        }
    }
}
