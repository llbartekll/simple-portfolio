import Foundation

protocol PortfolioServiceProtocol: Sendable {
    func fetchTokenBalances(address: String) async throws -> [Token]
    func fetchNFTCollections(address: String) async throws -> [NFTCollection]
}
