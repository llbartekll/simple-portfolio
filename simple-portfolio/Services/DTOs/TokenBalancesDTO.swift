import Foundation

// MARK: - Portfolio API (tokens/by-address)

struct TokenBalancesRequest: Encodable, Sendable {
    let addresses: [AddressEntry]
    let withMetadata: Bool
    let withPrices: Bool
    let includeNativeTokens: Bool
    let includeErc20Tokens: Bool

    struct AddressEntry: Encodable, Sendable {
        let address: String
        let networks: [String]
    }
}

struct TokenBalancesResponse: Decodable, Sendable {
    let data: TokenData

    struct TokenData: Decodable, Sendable {
        let tokens: [TokenEntry]
        let pageKey: String?
    }

    struct TokenEntry: Decodable, Sendable {
        let network: String
        let address: String
        let tokenAddress: String?
        let tokenBalance: String
        let tokenMetadata: TokenMetadata?
    }

    struct TokenMetadata: Decodable, Sendable {
        let name: String?
        let symbol: String?
        let decimals: Int?
        let logo: String?
    }
}
