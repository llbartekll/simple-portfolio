import SwiftUI

@main
struct simple_portfolioApp: App {
    private let service: PortfolioServiceProtocol?

    private var isTesting: Bool {
        NSClassFromString("XCTestCase") != nil
    }

    init() {
        if let apiKey = ProcessInfo.processInfo.environment["ALCHEMY_API_KEY"],
           !apiKey.isEmpty {
            service = AlchemyPortfolioService(apiKey: apiKey)
        } else {
            service = nil
        }
    }

    var body: some Scene {
        WindowGroup {
            if isTesting {
                EmptyView()
            } else if let service {
                ContentView(service: service)
            } else {
                ErrorStateView(
                    message: PortfolioError.invalidAPIKey.localizedDescription,
                    retryAction: {}
                )
            }
        }
    }
}
