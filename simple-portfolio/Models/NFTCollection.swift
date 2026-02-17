import Foundation

struct NFTCollection: Identifiable, Hashable, Sendable {
    let id: String
    let network: String
    let contractAddress: String
    let name: String
    let symbol: String
    let tokenType: String
    let ownedCount: Int
    let floorPrice: Double?
    let imageURL: URL?

    var formattedFloorPrice: String? {
        guard let price = floorPrice else { return nil }
        return String(format: "%.2f ETH", price)
    }
}

extension NFTCollection {
    init(from entry: NFTContractsResponse.ContractEntry) {
        self.id = "eth-\(entry.address)"
        self.network = "eth-mainnet"
        self.contractAddress = entry.address
        self.name = entry.openSeaMetadata?.collectionName
            ?? entry.name
            ?? "Unknown Collection"
        self.symbol = entry.symbol ?? "???"
        self.tokenType = entry.tokenType ?? "ERC721"
        self.ownedCount = Int(entry.numDistinctTokensOwned ?? "0") ?? 0
        self.floorPrice = entry.openSeaMetadata?.floorPrice
        self.imageURL = entry.openSeaMetadata?.imageUrl.flatMap { URL(string: $0) }
    }

    static let mockList: [NFTCollection] = [
        NFTCollection(
            id: "eth-bayc",
            network: "eth-mainnet",
            contractAddress: "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D",
            name: "Bored Ape Yacht Club",
            symbol: "BAYC",
            tokenType: "ERC721",
            ownedCount: 2,
            floorPrice: 12.5,
            imageURL: URL(string: "https://i.seadn.io/gae/Ju9CkWtV-1Okvf45wo8UctR0qKQ_aF-TBEd9GJQn7fTPC_4bmzjmA7naWKLr7ZmQdVk9obz_hQpNO-cPqFj356YR7pATBatfxg96?w=500&auto=format")
        ),
        NFTCollection(
            id: "eth-azuki",
            network: "eth-mainnet",
            contractAddress: "0xED5AF388653567Af2F388E6224dC7C4b3241C544",
            name: "Azuki",
            symbol: "AZUKI",
            tokenType: "ERC721",
            ownedCount: 1,
            floorPrice: 5.2,
            imageURL: URL(string: "https://i.seadn.io/gcs/files/4808a224e3483dfc65c2dbb4e446a27f.png?w=500&auto=format")
        ),
    ]
}
