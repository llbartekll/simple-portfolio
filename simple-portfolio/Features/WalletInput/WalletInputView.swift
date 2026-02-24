import SwiftUI

struct WalletInputView: View {
    @State private var viewModel = WalletInputViewModel()
    var onSubmit: (String) -> Void

    var body: some View {
        VStack(spacing: PFSpacing.xl.rawValue) {
            Spacer()

            VStack(spacing: PFSpacing.sm.rawValue) {
                Image(systemName: "wallet.bifold.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.pfAccent)

                Text("Portfolio Viewer")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.pfTextPrimary)

                Text("Enter an Ethereum or Solana wallet address to view its portfolio")
                    .font(.body)
                    .foregroundStyle(Color.pfTextTertiary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: PFSpacing.md.rawValue) {
                HStack(spacing: PFSpacing.sm.rawValue) {
                    TextField("0x... or Solana address", text: $viewModel.address)
                        .font(.body.monospaced())
                        .foregroundStyle(Color.pfTextPrimary)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .accessibilityLabel("Wallet address")
                        .onChange(of: viewModel.address) {
                            viewModel.validate()
                        }

                    Button {
                        viewModel.pasteFromClipboard()
                    } label: {
                        Image(systemName: "doc.on.clipboard")
                            .foregroundStyle(Color.pfTextSecondary)
                    }
                    .accessibilityLabel("Paste address from clipboard")
                }
                .padding(PFSpacing.md.rawValue)
                .background(Color.pfSurfaceRaised)
                .clipShape(RoundedRectangle(cornerRadius: PFRadius.md.rawValue, style: .continuous))

                if let error = viewModel.validationError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Color.pfNegative)
                }
            }

            Button {
                onSubmit(viewModel.address)
            } label: {
                Text("View Portfolio")
                    .font(.headline)
                    .foregroundStyle(Color.pfTextPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PFSpacing.md.rawValue)
            }
            .background(viewModel.canSubmit ? Color.pfAccent : Color.pfSurfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: PFRadius.md.rawValue, style: .continuous))
            .disabled(!viewModel.canSubmit)
            .accessibilityLabel("View portfolio")

            Spacer()
        }
        .padding(.horizontal, PFSpacing.lg.rawValue)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pfBackground)
    }
}

#Preview {
    WalletInputView { address in
        print("Submitted: \(address)")
    }
}
