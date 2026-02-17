import Foundation

@MainActor
@Observable
final class TokenDetailViewModel {
    let token: Token

    init(token: Token) {
        self.token = token
    }

    var truncatedContractAddress: String {
        let address = token.tokenAddress
        if address == "native" { return "Native Token" }
        guard address.count > 12 else { return address }
        let prefix = address.prefix(8)
        let suffix = address.suffix(4)
        return "\(prefix)...\(suffix)"
    }

    var isNativeToken: Bool {
        token.tokenAddress == "native"
    }
}
