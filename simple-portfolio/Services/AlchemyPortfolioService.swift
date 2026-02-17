import Foundation

final class AlchemyPortfolioService: PortfolioServiceProtocol {
    private let apiKey: String
    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    // MARK: - Token Balances

    func fetchTokenBalances(address: String) async throws -> [Token] {
        guard let url = URL(string: "https://api.g.alchemy.com/data/v1/\(apiKey)/assets/tokens/by-address") else {
            throw PortfolioError.requestFailed
        }
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

        let decoded: TokenBalancesResponse
        do {
            decoded = try JSONDecoder().decode(TokenBalancesResponse.self, from: data)
        } catch {
            throw PortfolioError.decodingFailed
        }

        return decoded.data.tokens
            .filter { !isZeroBalance($0.tokenBalance) }
            .prefix(20)
            .map { Token(from: $0) }
    }

    // MARK: - NFT Collections

    func fetchNFTCollections(address: String) async throws -> [NFTCollection] {
        var components = URLComponents(string: "https://eth-mainnet.g.alchemy.com/nft/v3/\(apiKey)/getContractsForOwner")
        components?.queryItems = [
            URLQueryItem(name: "owner", value: address),
            URLQueryItem(name: "pageSize", value: "50"),
        ]
        guard let url = components?.url else {
            throw PortfolioError.requestFailed
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")

        let (data, response) = try await performRequest(request)
        try validateResponse(response)

        let nftResponse: NFTContractsResponse
        do {
            nftResponse = try JSONDecoder().decode(NFTContractsResponse.self, from: data)
        } catch {
            throw PortfolioError.decodingFailed
        }

        var collections: [NFTCollection] = []
        for contract in nftResponse.contracts where contract.isSpam != true {
            collections.append(NFTCollection(from: contract))
        }
        return collections
    }

    // MARK: - Private Helpers

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await withRetry {
            do {
                return try await self.session.data(for: request)
            } catch {
                throw PortfolioError.requestFailed
            }
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw PortfolioError.requestFailed
        }
        if http.statusCode == 401 || http.statusCode == 403 {
            throw PortfolioError.invalidAPIKey
        }
        guard (200...299).contains(http.statusCode) else {
            throw PortfolioError.requestFailed
        }
    }

    private func isZeroBalance(_ value: String) -> Bool {
        if value.hasPrefix("0x") {
            let cleaned = String(value.dropFirst(2))
            return cleaned.isEmpty || cleaned.allSatisfy { $0 == "0" }
        }
        return value.isEmpty || Decimal(string: value) == 0
    }
}
