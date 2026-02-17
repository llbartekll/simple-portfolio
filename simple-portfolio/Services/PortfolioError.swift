import Foundation

enum PortfolioError: LocalizedError {
    case requestFailed
    case decodingFailed
    case invalidAPIKey

    var errorDescription: String? {
        switch self {
        case .requestFailed: "Network request failed. Please try again."
        case .decodingFailed: "Failed to parse server response."
        case .invalidAPIKey: "API key is missing. Set ALCHEMY_API_KEY environment variable."
        }
    }
}
