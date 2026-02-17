import SwiftUI
import UIKit

struct TokenDetailView: View {
    @State private var viewModel: TokenDetailViewModel
    @State private var copiedAddress = false

    init(token: Token) {
        _viewModel = State(initialValue: TokenDetailViewModel(token: token))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: PFSpacing.xl.rawValue) {
                tokenHeader
                balanceCard
                infoCard
            }
            .padding(.horizontal, PFSpacing.lg.rawValue)
            .padding(.vertical, PFSpacing.md.rawValue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pfBackground)
        .navigationTitle(viewModel.token.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var tokenHeader: some View {
        VStack(spacing: PFSpacing.md.rawValue) {
            AsyncImage(url: viewModel.token.logoURL) { phase in
                switch phase {
                case .empty:
                    Circle()
                        .fill(Color.pfSurfaceRaised)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.pfTextTertiary)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())

            Text(viewModel.token.symbol)
                .font(.title2.bold())
                .foregroundStyle(Color.pfTextSecondary)
        }
    }

    private var balanceCard: some View {
        VStack(spacing: PFSpacing.sm.rawValue) {
            Text("Balance")
                .font(.caption)
                .foregroundStyle(Color.pfTextTertiary)

            Text(viewModel.token.formattedBalance)
                .font(.largeTitle.bold().monospacedDigit())
                .foregroundStyle(Color.pfTextPrimary)

            Text(viewModel.token.symbol)
                .font(.headline)
                .foregroundStyle(Color.pfTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(PFSpacing.xl.rawValue)
        .background(Color.pfSurface)
        .clipShape(RoundedRectangle(cornerRadius: PFRadius.md.rawValue, style: .continuous))
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            infoRow(label: "Network", value: viewModel.token.network)
            Divider().overlay(Color.pfSurfaceRaised)
            contractAddressRow
            Divider().overlay(Color.pfSurfaceRaised)
            infoRow(label: "Symbol", value: viewModel.token.symbol)
            Divider().overlay(Color.pfSurfaceRaised)
            infoRow(label: "Decimals", value: "\(viewModel.token.decimals)")
        }
        .background(Color.pfSurface)
        .clipShape(RoundedRectangle(cornerRadius: PFRadius.md.rawValue, style: .continuous))
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(Color.pfTextSecondary)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundStyle(Color.pfTextPrimary)
        }
        .padding(.horizontal, PFSpacing.lg.rawValue)
        .padding(.vertical, PFSpacing.md.rawValue)
    }

    private var contractAddressRow: some View {
        HStack {
            Text("Contract")
                .font(.body)
                .foregroundStyle(Color.pfTextSecondary)
            Spacer()
            Button {
                if !viewModel.isNativeToken {
                    UIPasteboard.general.string = viewModel.token.tokenAddress
                    copiedAddress = true
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        copiedAddress = false
                    }
                }
            } label: {
                HStack(spacing: PFSpacing.xs.rawValue) {
                    Text(copiedAddress ? "Copied!" : viewModel.truncatedContractAddress)
                        .font(.body.monospaced())
                        .foregroundStyle(copiedAddress ? Color.pfPositive : Color.pfTextPrimary)
                    if !copiedAddress && !viewModel.isNativeToken {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                            .foregroundStyle(Color.pfTextTertiary)
                    }
                }
            }
            .disabled(viewModel.isNativeToken)
            .accessibilityLabel("Copy contract address")
        }
        .padding(.horizontal, PFSpacing.lg.rawValue)
        .padding(.vertical, PFSpacing.md.rawValue)
    }
}

#Preview {
    NavigationStack {
        TokenDetailView(token: Token.mockList[0])
    }
}
