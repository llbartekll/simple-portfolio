Audit the specified file(s) against project conventions. If no file is specified, review all Swift files in the current changeset (`git diff --name-only`).

For each file, check every item and report **PASS** or **FAIL** with line numbers.

## Checklist

1. **No Combine** — `import Combine` must not appear
2. **No force unwraps on API data** — no `!` on decoded/optional API values (force unwrap on static/known-safe values is OK)
3. **Design tokens only** — colors use `Color.pf*` tokens, no raw `Color.red`, `Color(hex:)`, etc.
4. **@Observable** — view models use `@Observable`, not `ObservableObject` / `@Published`
5. **ViewState<T>** — async screens use `ViewState<T>` with all 4 cases handled (`loading`, `loaded`, `error`, `empty`)
6. **#Preview present** — every view file has a `#Preview` macro
7. **Data loading via .task{}** — no `onAppear` + `Task {}` pattern
8. **Protocol-based services** — services are accessed via protocol types, not concrete classes
9. **Spacing & radius tokens** — uses `PFSpacing` / `PFRadius`, no magic numbers for padding/radius
10. **Accessibility labels** — interactive elements (buttons, links, toggles) have `.accessibilityLabel`
11. **Correct directory** — file is in the expected `Features/`, `Components/`, `Services/`, etc. folder

## Output Format

```
## <FileName>.swift

 1. No Combine                  PASS
 2. No force unwraps (API)      FAIL — line 42: `response.data!`
 3. Design tokens only          PASS
 ...

Score: 9/11
```

After all files, output a summary: total files checked, overall pass rate, and top issues to fix.
