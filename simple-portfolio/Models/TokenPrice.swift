import Foundation

struct TokenPrice: Sendable {
    let raw: Double
    let currency: String

    var formattedUSD: String {
        if raw >= 1_000 {
            return String(format: "$%.2f", raw)
        }
        if raw >= 1 {
            return String(format: "$%.2f", raw)
        }
        if raw >= 0.01 {
            return String(format: "$%.4f", raw)
        }
        if raw > 0 {
            return String(format: "$%.6f", raw)
        }
        return "$0.00"
    }
}
