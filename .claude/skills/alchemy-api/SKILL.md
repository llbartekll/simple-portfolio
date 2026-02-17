---
description: "Alchemy Portfolio API patterns, endpoint specs, and Codable model templates"
triggers:
  - "API"
  - "networking"
  - "fetch tokens"
  - "fetch NFTs"
  - "Alchemy"
  - "service"
  - "HTTP"
  - "endpoint"
---

# Alchemy Portfolio API Skill

## Base URL & Auth

- **Base URL:** `https://api.g.alchemy.com/data/v1/{apiKey}/assets/`
- API key is a URL path segment — **never hardcode it**
- Load from `.xcconfig` or environment variable
- Token endpoint is **POST** with `Content-Type: application/json`
- NFT endpoint uses a **different base URL** and is **GET** (see below)

## Token Balances Endpoint

**Path:** `tokens/by-address`

Returns token balances **with metadata** in a single call (no need for separate metadata requests). Balances are **hex strings** (e.g. `"0x14D1120D7B160000"`).

### Request Body

```json
{
  "addresses": [
    { "address": "0xABC123...", "networks": ["eth-mainnet"] }
  ],
  "withMetadata": true,
  "withPrices": false,
  "includeNativeTokens": true,
  "includeErc20Tokens": true
}
```

### Swift Request Model (in `Services/DTOs/TokenBalancesDTO.swift`)

```swift
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
```

### Response Body

```json
{
  "data": {
    "tokens": [
      {
        "network": "eth-mainnet",
        "address": "0xABC123...",
        "tokenAddress": "0xDEF456...",
        "tokenBalance": "0x0DE0B6B3A7640000",
        "tokenMetadata": {
          "name": "Ethereum",
          "symbol": "ETH",
          "decimals": 18,
          "logo": "https://..."
        }
      }
    ],
    "pageKey": "abc123"
  }
}
```

Note: `tokenBalance` is a **hex string** (e.g. `"0x0DE0B6B3A7640000"`). `tokenAddress` is `null` for native tokens (metadata will be all `null` for native tokens — handle with fallbacks).

### Swift Response Model (in `Services/DTOs/TokenBalancesDTO.swift`)

```swift
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
```

## NFT Collections Endpoint

**URL:** `GET https://eth-mainnet.g.alchemy.com/nft/v3/{apiKey}/getContractsForOwner?owner={address}&pageSize=50`

Note: This uses the **NFT v3 REST API**, not the Portfolio Assets API. It is a **GET** request with query parameters.

### Response Body (key fields)

```json
{
  "contracts": [
    {
      "address": "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D",
      "name": "BoredApeYachtClub",
      "symbol": "BAYC",
      "tokenType": "ERC721",
      "numDistinctTokensOwned": "3",
      "isSpam": false,
      "totalBalance": "3",
      "openSeaMetadata": {
        "floorPrice": 12.5,
        "collectionName": "Bored Ape Yacht Club",
        "imageUrl": "https://..."
      }
    }
  ],
  "pageKey": "abc123"
}
```

### Swift Response Model (in `Services/DTOs/NFTContractsDTO.swift`)

```swift
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
```

## Service Protocol

```swift
protocol PortfolioServiceProtocol: Sendable {
    func fetchTokenBalances(address: String) async throws -> [Token]
    func fetchNFTCollections(address: String) async throws -> [NFTCollection]
}
```

## URLSession Pattern (actual implementation in `Services/AlchemyPortfolioService.swift`)

```swift
func fetchTokenBalances(address: String) async throws -> [Token] {
    let url = URL(string: "https://api.g.alchemy.com/data/v1/\(apiKey)/assets/tokens/by-address")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body = TokenBalancesRequest(
        addresses: [.init(address: address, networks: ["eth-mainnet"])],
        withMetadata: true,
        withPrices: false,
        includeNativeTokens: true,
        includeErc20Tokens: true
    )
    request.httpBody = try JSONEncoder().encode(body)

    let (data, response) = try await performRequest(request)
    try validateResponse(response)

    let decoded = try JSONDecoder().decode(TokenBalancesResponse.self, from: data)
    return decoded.data.tokens
        .filter { !isZeroBalance($0.tokenBalance) }
        .prefix(20)
        .map { Token(from: $0) }
}
```

## Token Model (in `Models/Token.swift`)

```swift
extension Token {
    init(from entry: TokenBalancesResponse.TokenEntry) {
        self.id = "\(entry.network)-\(entry.tokenAddress ?? "native")"
        self.network = entry.network
        self.tokenAddress = entry.tokenAddress ?? "native"
        let isNative = entry.tokenAddress == nil
        self.name = entry.tokenMetadata?.name.flatMap { $0.isEmpty ? nil : $0 }
            ?? (isNative ? "Ethereum" : "Unknown Token")
        self.symbol = entry.tokenMetadata?.symbol.flatMap { $0.isEmpty ? nil : $0 }
            ?? (isNative ? "ETH" : "???")
        self.decimals = entry.tokenMetadata?.decimals ?? 18
        self.rawBalance = entry.tokenBalance
        self.logoURL = entry.tokenMetadata?.logo.flatMap { URL(string: $0) }
    }
}
```

Balance is a hex string — parsed via `Token.hexToBalance` (hex → Decimal → Double).

## Mock Service

```swift
final class MockPortfolioService: PortfolioServiceProtocol {
    var tokensToReturn: [Token] = Token.mockList
    var nftsToReturn: [NFTCollection] = NFTCollection.mockList
    var shouldThrow = false

    func fetchTokenBalances(address: String) async throws -> [Token] {
        if shouldThrow { throw PortfolioError.requestFailed }
        return tokensToReturn
    }

    func fetchNFTCollections(address: String) async throws -> [NFTCollection] {
        if shouldThrow { throw PortfolioError.requestFailed }
        return nftsToReturn
    }
}
```
