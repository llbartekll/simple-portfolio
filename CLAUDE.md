# simple-portfolio

SwiftUI portfolio viewer for iOS 17+, Swift 5. Three screens:
1. **Wallet Input** — enter an Ethereum address
2. **Portfolio List** — tokens & NFT collections for that address
3. **Token Detail** — basic info for a single token

No auth, no persistence. Data fetched on-demand from Alchemy API.

## Architecture

| Layer | Tech |
|-------|------|
| UI | SwiftUI + MVVM with `@Observable` |
| Navigation | Typed `NavigationPath` |
| Services | Protocol + `async/await` |
| State | Generic `ViewState<T>` enum |

## File Organization

```
simple-portfolio/             — Entry point (App, ContentView), root navigation
Models/                       — Token, NFTCollection, API DTOs
Services/                     — PortfolioServiceProtocol + implementation
Features/
  WalletInput/                — Address entry screen
  Portfolio/                  — Token & NFT collection list
  TokenDetail/                — Single token info
Components/                   — Reusable UI (ErrorStateView, EmptyStateView, LoadingView)
DesignSystem/                 — Colors, Spacing tokens
Preview/                      — Mock data, preview helpers
```

## Rules — NEVER

- `import Combine` — use async/await exclusively
- Force unwraps (`!`) on API/decoded data
- Raw color literals (`Color.red`, `Color(hex:)`) — use `Color.pf*` tokens only
- UIKit wrappers (`UIViewRepresentable`, `UIViewControllerRepresentable`)

## Rules — ALWAYS

- `@Observable` view models (not `ObservableObject`/`@Published`)
- `ViewState<T>` for every async screen — handle all 4 cases (loading, loaded, error, empty)
- `#Preview` macro for every view
- `.task {}` for data loading — never `onAppear` with Task
- Protocol-based services (`PortfolioServiceProtocol`)
- Accessibility labels on all interactive elements

## API — Alchemy

- **Token Balances:** `POST https://api.g.alchemy.com/data/v1/{apiKey}/assets/tokens/by-address`
- **NFT Collections:** `GET https://eth-mainnet.g.alchemy.com/nft/v3/{apiKey}/getContractsForOwner?owner={address}`
- **Auth:** API key in URL path segment. **NEVER commit the key.** Use `.xcconfig` or environment variable.

## Build

```bash
xcodebuild -scheme simple-portfolio \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.3.1' \
  build 2>&1 | tail -80
```

## Canonical References

- `DesignSystem/Colors.swift` — all `Color.pf*` tokens
- `DesignSystem/Spacing.swift` — `PFSpacing` and `PFRadius` enums

## Skills

- **UI work** — see `swiftui-dev` skill for design tokens, view/VM templates, component patterns
- **Networking** — see `alchemy-api` skill for endpoint specs, Codable models, service templates
