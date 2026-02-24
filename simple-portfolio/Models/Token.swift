import Foundation

struct Token: Identifiable, Hashable, Sendable {
    let id: String
    let network: String
    let tokenAddress: String
    let name: String
    let symbol: String
    let decimals: Int
    let rawBalance: String
    let logoURL: URL?

    var formattedBalance: String {
        let balance = rawBalance.hasPrefix("0x")
            ? Self.hexToBalance(rawBalance, decimals: decimals)
            : Self.decimalStringToBalance(rawBalance, decimals: decimals)
        if balance == 0 { return "0" }
        if balance < 0.0001 { return "<0.0001" }
        if balance >= 1_000_000 {
            return String(format: "%.2fM", balance / 1_000_000)
        }
        if balance >= 1_000 {
            return String(format: "%.2f", balance)
        }
        return String(format: "%.4f", balance)
    }

    private static func hexToBalance(_ hex: String, decimals: Int) -> Double {
        let cleaned = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
        guard !cleaned.isEmpty else { return 0 }
        var result = Decimal(0)
        let base = Decimal(16)
        for char in cleaned {
            guard let digit = Int(String(char), radix: 16) else { return 0 }
            result = result * base + Decimal(digit)
        }
        let divisor = pow(Decimal(10), decimals)
        let balance = result / divisor
        return NSDecimalNumber(decimal: balance).doubleValue
    }

    private static func decimalStringToBalance(_ value: String, decimals: Int) -> Double {
        guard let raw = Decimal(string: value) else { return 0 }
        let divisor = pow(Decimal(10), decimals)
        let balance = raw / divisor
        return NSDecimalNumber(decimal: balance).doubleValue
    }
}

extension Token {
    init(from entry: TokenBalancesResponse.TokenEntry) {
        let isNative = entry.tokenAddress == nil
        self.id = "\(entry.network)-\(entry.tokenAddress ?? "native")"
        self.network = entry.network
        self.tokenAddress = entry.tokenAddress ?? "native"
        let isSolana = entry.network == "solana-mainnet"
        self.name = entry.tokenMetadata?.name.flatMap { $0.isEmpty ? nil : $0 }
            ?? (isNative ? (isSolana ? "Solana" : "Ethereum") : "Unknown Token")
        self.symbol = entry.tokenMetadata?.symbol.flatMap { $0.isEmpty ? nil : $0 }
            ?? (isNative ? (isSolana ? "SOL" : "ETH") : "???")
        self.decimals = entry.tokenMetadata?.decimals ?? (isSolana ? 9 : 18)
        self.rawBalance = entry.tokenBalance
        self.logoURL = entry.tokenMetadata?.logo.flatMap { URL(string: $0) }
    }

    static let mockList: [Token] = [
        Token(
            id: "eth-mainnet-native",
            network: "eth-mainnet",
            tokenAddress: "native",
            name: "Ethereum",
            symbol: "ETH",
            decimals: 18,
            rawBalance: "0x14D1120D7B160000",
            logoURL: URL(string: "https://static.alchemyapi.io/images/assets/1027.png")
        ),
        Token(
            id: "eth-mainnet-0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
            network: "eth-mainnet",
            tokenAddress: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
            name: "USD Coin",
            symbol: "USDC",
            decimals: 6,
            rawBalance: "0x9502F900",
            logoURL: URL(string: "https://static.alchemyapi.io/images/assets/3408.png")
        ),
        Token(
            id: "eth-mainnet-0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
            network: "eth-mainnet",
            tokenAddress: "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
            name: "Uniswap",
            symbol: "UNI",
            decimals: 18,
            rawBalance: "0x2B5E3AF16B1880000",
            logoURL: URL(string: "https://static.alchemyapi.io/images/assets/7083.png")
        ),
        Token(
            id: "solana-mainnet-native",
            network: "solana-mainnet",
            tokenAddress: "native",
            name: "Solana",
            symbol: "SOL",
            decimals: 9,
            rawBalance: "1500000000",
            logoURL: URL(string: "https://static.alchemyapi.io/images/assets/5426.png")
        ),
        Token(
            id: "solana-mainnet-EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            network: "solana-mainnet",
            tokenAddress: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            name: "USD Coin",
            symbol: "USDC",
            decimals: 6,
            rawBalance: "5000000000",
            logoURL: URL(string: "https://static.alchemyapi.io/images/assets/3408.png")
        ),
    ]
}
