import Foundation

final class MockPortfolioService: PortfolioServiceProtocol, @unchecked Sendable {
    var tokensToReturn: [Token] = Token.mockList
    var nftsToReturn: [NFTCollection] = NFTCollection.mockList
    var shouldThrow = false
    var delay: Duration = .milliseconds(500)

    func fetchTokenBalances(address: String) async throws -> [Token] {
        try await Task.sleep(for: delay)
        if shouldThrow { throw PortfolioError.requestFailed }
        return tokensToReturn
    }

    func fetchNFTCollections(address: String) async throws -> [NFTCollection] {
        try await Task.sleep(for: delay)
        if shouldThrow { throw PortfolioError.requestFailed }
        return nftsToReturn
    }
}
