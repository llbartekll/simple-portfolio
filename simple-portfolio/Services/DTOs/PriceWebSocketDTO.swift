import Foundation

struct PriceAssetIdentifier: Codable, Hashable {
    let chainId: Int
    let address: String
}

struct PriceSubscribeMessage: Encodable {
    let type: String = "subscribe"
    let assetIdentifier: PriceAssetIdentifier
}

struct PriceUpdateMessage: Decodable {
    let assetIdentifier: PriceAssetIdentifier
    let price: PricePayload

    struct PricePayload: Decodable {
        let raw: Double
        let currency: String
        let usdValue: String
    }
}
