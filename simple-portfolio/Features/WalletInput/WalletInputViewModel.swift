import UIKit

@MainActor
@Observable
final class WalletInputViewModel {
    var address: String = ""
    var validationError: String?

    var isValid: Bool {
        address.hasPrefix("0x") && address.count == 42
    }

    var canSubmit: Bool {
        isValid && validationError == nil
    }

    func validate() {
        if address.isEmpty {
            validationError = nil
        } else if !address.hasPrefix("0x") {
            validationError = "Address must start with 0x"
        } else if address.count != 42 {
            validationError = "Address must be 42 characters"
        } else {
            validationError = nil
        }
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
