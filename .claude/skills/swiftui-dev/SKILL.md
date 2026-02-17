---
description: "Design system tokens, view/VM templates, and component patterns"
triggers:
  - "create a view"
  - "add a screen"
  - "new feature"
  - "build component"
  - "design"
  - "UI"
  - "colors"
  - "styling"
---

# SwiftUI Development Skill

## Color Palette (Dark-First)

| Token | Hex | Usage |
|-------|-----|-------|
| `Color.pfBackground` | `#09090B` | App background |
| `Color.pfSurface` | `#18181B` | Card/section background |
| `Color.pfSurfaceRaised` | `#27272A` | Elevated elements, inputs |
| `Color.pfTextPrimary` | `#FFFFFF` | Primary text |
| `Color.pfTextSecondary` | `#A1A1AA` | Secondary/supporting text |
| `Color.pfTextTertiary` | `#71717A` | Captions, timestamps |
| `Color.pfAccent` | `#6366F1` | Buttons, links, highlights |
| `Color.pfPositive` | `#22C55E` | Gains, success states |
| `Color.pfNegative` | `#EF4444` | Losses, error states |

### Swift Definition

```swift
import SwiftUI

extension Color {
    static let pfBackground     = Color(red: 0.035, green: 0.035, blue: 0.043)
    static let pfSurface        = Color(red: 0.094, green: 0.094, blue: 0.106)
    static let pfSurfaceRaised  = Color(red: 0.153, green: 0.153, blue: 0.165)
    static let pfTextPrimary    = Color.white
    static let pfTextSecondary  = Color(red: 0.631, green: 0.631, blue: 0.667)
    static let pfTextTertiary   = Color(red: 0.443, green: 0.443, blue: 0.478)
    static let pfAccent         = Color(red: 0.388, green: 0.400, blue: 0.945)
    static let pfPositive       = Color(red: 0.133, green: 0.773, blue: 0.369)
    static let pfNegative       = Color(red: 0.937, green: 0.267, blue: 0.267)
}
```

## Spacing Scale

| Token | Value |
|-------|-------|
| `PFSpacing.xs` | 4 |
| `PFSpacing.sm` | 8 |
| `PFSpacing.md` | 12 |
| `PFSpacing.lg` | 16 |
| `PFSpacing.xl` | 24 |
| `PFSpacing.xxl` | 32 |
| `PFSpacing.xxxl` | 48 |

```swift
enum PFSpacing: CGFloat {
    case xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32, xxxl = 48
}
```

## Corner Radius

| Token | Value |
|-------|-------|
| `PFRadius.sm` | 8 |
| `PFRadius.md` | 12 |
| `PFRadius.lg` | 16 |
| `PFRadius.full` | 9999 |

```swift
enum PFRadius: CGFloat {
    case sm = 8, md = 12, lg = 16, full = 9999
}
```

Always use `.continuous` style:
```swift
RoundedRectangle(cornerRadius: PFRadius.md.rawValue, style: .continuous)
```

## Typography

Use semantic `Font` API — supports Dynamic Type automatically.

| Style | Font | Usage |
|-------|------|-------|
| largeTitle | `.largeTitle.bold()` | Screen titles |
| title | `.title2.bold()` | Section headers |
| headline | `.headline` | Card titles |
| body | `.body` | Content text |
| caption | `.caption` | Timestamps, labels |
| mono | `.body.monospaced()` | Addresses, hashes |

## Generic ViewState

```swift
enum ViewState<T> {
    case loading
    case loaded(T)
    case error(String)
    case empty
}
```

Use this for **every** async screen. Always handle all 4 cases.

## View Template

```swift
import SwiftUI

struct FeatureView: View {
    @State private var viewModel: FeatureViewModel

    init(service: PortfolioServiceProtocol) {
        _viewModel = State(initialValue: FeatureViewModel(service: service))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingView()
            case .loaded(let data):
                // Content view
                Text("\(data)")
            case .error(let message):
                ErrorStateView(message: message) {
                    Task { await viewModel.load() }
                }
            case .empty:
                EmptyStateView(
                    title: "Nothing here",
                    subtitle: "Description",
                    systemImage: "tray"
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pfBackground)
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    FeatureView(service: MockPortfolioService())
}
```

## ViewModel Template

```swift
import Foundation

@Observable
final class FeatureViewModel {
    private let service: PortfolioServiceProtocol
    var state: ViewState<[Item]> = .loading

    init(service: PortfolioServiceProtocol) {
        self.service = service
    }

    func load() async {
        state = .loading
        do {
            let items = try await service.fetchItems()
            state = items.isEmpty ? .empty : .loaded(items)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
```

## AsyncImage Pattern

```swift
AsyncImage(url: imageURL) { phase in
    switch phase {
    case .empty:
        RoundedRectangle(cornerRadius: PFRadius.sm.rawValue, style: .continuous)
            .fill(Color.pfSurfaceRaised)
    case .success(let image):
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
    case .failure:
        Image(systemName: "photo")
            .foregroundStyle(Color.pfTextTertiary)
    @unknown default:
        EmptyView()
    }
}
```

## Component Signatures

```swift
EmptyStateView(title: String, subtitle: String, systemImage: String)
ErrorStateView(message: String, retryAction: () -> Void)
LoadingView()  // Shimmer placeholder
```

## Pre-Completion Checklist

Before finishing any view or feature, verify:

1. All async views use `ViewState<T>` with all 4 cases handled
2. `#Preview` macro exists
3. Only `Color.pf*` / `PFSpacing` / `PFRadius` tokens used — no raw colors or magic numbers
4. No `import Combine`
5. No force unwraps (`!`) on decoded/API data
6. Data loaded via `.task {}`
7. ViewModel uses `@Observable` (not `ObservableObject`)
8. Accessibility labels on all interactive elements
