import Foundation

protocol PriceServiceProtocol: AnyObject, Sendable {
    func priceUpdates(for tokens: [Token]) -> AsyncStream<[String: TokenPrice]>
    func disconnect()
}
