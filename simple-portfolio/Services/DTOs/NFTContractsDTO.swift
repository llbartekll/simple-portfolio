import Foundation

// MARK: - NFT v3 REST API (getContractsForOwner)

struct NFTContractsResponse: Decodable, Sendable {
    let contracts: [ContractEntry]
    let pageKey: String?

    struct ContractEntry: Decodable, Sendable {
        let address: String
        let name: String?
        let symbol: String?
        let tokenType: String?
        let numDistinctTokensOwned: String?
        let isSpam: Bool?
        let totalBalance: String?
        let openSeaMetadata: OpenSeaMetadata?
    }

    struct OpenSeaMetadata: Decodable, Sendable {
        let floorPrice: Double?
        let collectionName: String?
        let imageUrl: String?
    }
}
