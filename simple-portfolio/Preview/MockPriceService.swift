import Foundation

final class MockPriceService: PriceServiceProtocol, @unchecked Sendable {
    static let mockPrices: [String: TokenPrice] = [
        "eth-mainnet-native": TokenPrice(raw: 2_840.50, currency: "USD"),
        "eth-mainnet-0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48": TokenPrice(raw: 1.00, currency: "USD"),
        "eth-mainnet-0x1f9840a85d5af5bf1d1762f925bdaddc4201f984": TokenPrice(raw: 7.42, currency: "USD"),
        "solana-mainnet-native": TokenPrice(raw: 40.00, currency: "USD"),
        "solana-mainnet-EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v": TokenPrice(raw: 1.00, currency: "USD"),
    ]

    func priceUpdates(for tokens: [Token]) -> AsyncStream<[String: TokenPrice]> {
        AsyncStream { continuation in
            continuation.yield(Self.mockPrices)
            continuation.finish()
        }
    }

    func disconnect() {}
}
