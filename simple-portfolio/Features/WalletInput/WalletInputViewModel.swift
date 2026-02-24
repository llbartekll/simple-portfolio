import UIKit

@MainActor
@Observable
final class WalletInputViewModel {
    var address: String = ""
    var validationError: String?

    private static let base58Chars = CharacterSet(charactersIn: "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")

    var isValid: Bool {
        isValidEVM(address) || isValidSolana(address)
    }

    var canSubmit: Bool {
        isValid && validationError == nil
    }

    func validate() {
        if address.isEmpty {
            validationError = nil
        } else if address.hasPrefix("0x") {
            if address.count != 42 {
                validationError = "EVM address must be 42 characters"
            } else if !address.dropFirst(2).allSatisfy({ $0.isHexDigit }) {
                validationError = "EVM address contains invalid characters"
            } else {
                validationError = nil
            }
        } else {
            if address.count < 32 || address.count > 44 {
                validationError = "Solana address must be 32-44 characters"
            } else if !address.unicodeScalars.allSatisfy({ Self.base58Chars.contains($0) }) {
                validationError = "Solana address contains invalid characters"
            } else {
                validationError = nil
            }
        }
    }

    private func isValidEVM(_ addr: String) -> Bool {
        addr.hasPrefix("0x") && addr.count == 42 && addr.dropFirst(2).allSatisfy { $0.isHexDigit }
    }

    private func isValidSolana(_ addr: String) -> Bool {
        (32...44).contains(addr.count) && addr.unicodeScalars.allSatisfy { Self.base58Chars.contains($0) }
    }

    func pasteFromClipboard() {
        #if canImport(UIKit)
        if let text = UIPasteboard.general.string {
            address = text.trimmingCharacters(in: .whitespacesAndNewlines)
            validate()
        }
        #endif
    }
}
