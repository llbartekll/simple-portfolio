import SwiftUI

enum Route: Hashable {
    case portfolio(address: String)
    case tokenDetail(Token)
}

struct ContentView: View {
    @State private var path = NavigationPath()
    let service: PortfolioServiceProtocol

    var body: some View {
        NavigationStack(path: $path) {
            WalletInputView { address in
                path.append(Route.portfolio(address: address))
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .portfolio(let address):
                    PortfolioView(address: address, service: service) { token in
                        path.append(Route.tokenDetail(token))
                    }
                case .tokenDetail(let token):
                    TokenDetailView(token: token)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView(service: MockPortfolioService())
}
