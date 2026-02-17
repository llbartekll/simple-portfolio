import Foundation

func withRetry<T>(
    maxAttempts: Int = 3,
    initialDelay: Duration = .milliseconds(500),
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?

    for attempt in 0..<maxAttempts {
        try Task.checkCancellation()
        do {
            return try await operation()
        } catch let error as PortfolioError where error == .requestFailed {
            lastError = error
            if attempt < maxAttempts - 1 {
                let multiplier = 1 << attempt
                try await Task.sleep(for: initialDelay * multiplier)
            }
        }
    }

    throw lastError!
}
