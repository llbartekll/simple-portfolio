# Simple Portfolio

A lightweight SwiftUI portfolio viewer that displays Ethereum token balances and NFT collections for any wallet address. Three screens, no auth, no persistence — data fetched on-demand from the Alchemy API.

## Requirements

- iOS 17+
- Xcode 15+
- Swift 5
- An [Alchemy](https://www.alchemy.com/) API key

## Setup & Run

1. Clone the repo
2. Open `simple-portfolio.xcodeproj` in Xcode
3. Set your Alchemy API key in the scheme:
   **Edit Scheme → Run → Environment Variables** → set `ALCHEMY_API_KEY`
4. Select a simulator and run

## Architecture

| Aspect | Approach |
|--------|----------|
| UI | SwiftUI + MVVM with `@Observable` |
| Async | `async/await` (no Combine) |
| State | Generic `ViewState<T>` — loading, loaded, error, empty |
| Services | Protocol-based (`PortfolioServiceProtocol`) |
| Navigation | Typed `NavigationPath` |

## Project Structure

```
simple-portfolio/
├── simple_portfolioApp.swift        # Entry point
├── ContentView.swift                # Root navigation
├── Models/
│   ├── Token.swift
│   ├── NFTCollection.swift
│   └── ViewState.swift
├── Services/
│   ├── PortfolioServiceProtocol.swift
│   ├── AlchemyPortfolioService.swift
│   ├── PortfolioError.swift
│   ├── RetryHelper.swift
│   └── DTOs/                        # Alchemy API response models
├── Features/
│   ├── WalletInput/                 # Address entry screen
│   ├── Portfolio/                   # Token & NFT collection list
│   └── TokenDetail/                 # Single token info
├── Components/                      # Reusable UI (ErrorState, EmptyState, Loading)
├── DesignSystem/                    # Color & spacing tokens
└── Preview/                         # Mock data & preview helpers
```

## AI-Assisted Development

This project includes [Claude Code](https://docs.anthropic.com/en/docs/claude-code) configuration for AI-assisted development.

| Resource | Purpose |
|----------|---------|
| `CLAUDE.md` | Project rules, architecture reference, and coding conventions |
| `alchemy-api` skill | Alchemy endpoint specs, Codable model templates, service patterns |
| `swiftui-dev` skill | Design system tokens, view/VM templates, component patterns |
| `/build` command | Build the project and report results |
| `/review-conventions` command | Run an 11-point convention audit against project rules |

## Known Limitations

- **No pagination** — Token balances and NFT collections are fetched in a single request. Wallets with a large number of tokens or NFT collections may return incomplete results.
