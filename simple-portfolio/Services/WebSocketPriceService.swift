import Foundation
import os

private let logger = Logger(subsystem: "com.soberkit.simple-portfolio", category: "WebSocketPriceService")

final class WebSocketPriceService: PriceServiceProtocol, @unchecked Sendable {
    private let url = URL(string: "wss://websocket-floor-test-732ef4f89e9d.herokuapp.com")!
    private var webSocketTask: URLSessionWebSocketTask?
    private let session: URLSession

    private static let chainIdMap: [String: Int] = [
        "eth-mainnet": 1,
        "polygon-mainnet": 137,
        "arb-mainnet": 42161,
        "opt-mainnet": 10,
        "base-mainnet": 8453,
    ]

    private static let zeroAddress = "0x0000000000000000000000000000000000000000"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func priceUpdates(for tokens: [Token]) -> AsyncStream<[String: TokenPrice]> {
        disconnect()

        logger.info("Connecting to WebSocket: \(self.url.absoluteString)")
        let task = session.webSocketTask(with: url)
        webSocketTask = task
        task.resume()

        let tokenLookup = buildTokenLookup(tokens)
        logger.info("Token lookup built with \(tokenLookup.count) entries:")
        for (key, value) in tokenLookup {
            logger.info("  chainId=\(key.chainId), address=\(key.address) → tokenId=\(value)")
        }

        let priceState = PriceState()

        return AsyncStream { continuation in
            continuation.onTermination = { [weak self] reason in
                logger.info("AsyncStream terminated: \(String(describing: reason))")
                self?.disconnect()
            }

            Task { [weak self] in
                guard let self else {
                    logger.warning("WebSocketPriceService deallocated before stream started")
                    continuation.finish()
                    return
                }

                do {
                    try await self.subscribe(tokens: tokens, task: task)
                    try await self.receiveMessages(
                        task: task,
                        tokenLookup: tokenLookup,
                        priceState: priceState,
                        continuation: continuation
                    )
                } catch {
                    logger.error("WebSocket error: \(error.localizedDescription)")
                    if !Task.isCancelled {
                        try? await Task.sleep(for: .seconds(3))
                    }
                    continuation.finish()
                }
            }
        }
    }

    func disconnect() {
        logger.info("Disconnecting WebSocket")
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
    }

    // MARK: - Private

    private func buildTokenLookup(_ tokens: [Token]) -> [PriceAssetIdentifier: String] {
        var lookup: [PriceAssetIdentifier: String] = [:]
        for token in tokens {
            let chainId = Self.chainIdMap[token.network] ?? 1
            let wsAddress = token.tokenAddress == "native"
                ? Self.zeroAddress
                : token.tokenAddress.lowercased()
            let identifier = PriceAssetIdentifier(chainId: chainId, address: wsAddress)
            lookup[identifier] = token.id
        }
        return lookup
    }

    private func subscribe(tokens: [Token], task: URLSessionWebSocketTask) async throws {
        let encoder = JSONEncoder()
        for token in tokens {
            let chainId = Self.chainIdMap[token.network] ?? 1
            let wsAddress = token.tokenAddress == "native"
                ? Self.zeroAddress
                : token.tokenAddress.lowercased()
            let message = PriceSubscribeMessage(
                assetIdentifier: PriceAssetIdentifier(chainId: chainId, address: wsAddress)
            )
            let data = try encoder.encode(message)
            let jsonString = String(data: data, encoding: .utf8) ?? "<failed to encode>"
            logger.info("Subscribing: \(jsonString)")
            try await task.send(.string(jsonString))
        }
        logger.info("All \(tokens.count) subscriptions sent")
    }

    private func receiveMessages(
        task: URLSessionWebSocketTask,
        tokenLookup: [PriceAssetIdentifier: String],
        priceState: PriceState,
        continuation: AsyncStream<[String: TokenPrice]>.Continuation
    ) async throws {
        let decoder = JSONDecoder()
        while !Task.isCancelled {
            let message = try await task.receive()

            let rawString: String?
            let data: Data?
            switch message {
            case .string(let text):
                rawString = text
                data = text.data(using: .utf8)
            case .data(let d):
                rawString = String(data: d, encoding: .utf8)
                data = d
            @unknown default:
                logger.warning("Unknown WebSocket message type")
                continue
            }

            logger.info("Received: \(rawString ?? "<nil>")")

            guard let data else {
                logger.warning("Could not get data from message")
                continue
            }

            guard let update = try? decoder.decode(PriceUpdateMessage.self, from: data) else {
                logger.warning("Failed to decode PriceUpdateMessage from: \(rawString ?? "<nil>")")
                continue
            }

            let lookupKey = PriceAssetIdentifier(
                chainId: update.assetIdentifier.chainId,
                address: update.assetIdentifier.address.lowercased()
            )
            logger.info("Decoded price update: chainId=\(lookupKey.chainId), address=\(lookupKey.address), raw=\(update.price.raw), usdValue=\(update.price.usdValue)")

            guard let tokenId = tokenLookup[lookupKey] else {
                logger.warning("No token found for lookup key chainId=\(lookupKey.chainId), address=\(lookupKey.address)")
                continue
            }

            let usdDouble = Double(update.price.usdValue) ?? 0
            let price = TokenPrice(raw: usdDouble, currency: "USD")
            let snapshot = await priceState.update(tokenId: tokenId, price: price)
            logger.info("Yielding price snapshot with \(snapshot.count) entries for tokenId=\(tokenId)")
            continuation.yield(snapshot)
        }
    }
}

// MARK: - PriceState Actor

private actor PriceState {
    private var prices: [String: TokenPrice] = [:]

    func update(tokenId: String, price: TokenPrice) -> [String: TokenPrice] {
        prices[tokenId] = price
        return prices
    }
}
