# FluxGit — Implementation Plan

An advanced hybrid Git client built with **Flutter** (Desktop & Android) using **libgit2dart** (FFI bindings) for atomic local operations, featuring multi-account auth, visual commit graph, conflict resolver, embedded terminal, and an educational onboarding system.

## User Review Required

> [!IMPORTANT]
> **Flutter SDK is not installed** on this system. Phase 0 requires installing Flutter before any code can be built. I will install it via `snap` or the official archive — please confirm your preference.

> [!WARNING]
> **isar** v3.1.0 is effectively unmaintained. The community fork `isar_community` v3.3.0 is actively maintained and drop-in compatible. I recommend using the fork. Please confirm.

> [!IMPORTANT]
> This is a **very large project**. I will implement it phase-by-phase. After each phase, I'll verify and checkpoint before moving on. The initial delivery will focus on **Phases 0–3** (foundation, auth, repository GUI) as the functional core. Phases 4–5 (terminal, academy) follow after.

---

## Architecture Overview

```
lib/
├── main.dart
├── app.dart                         # MaterialApp, theme, routing
├── core/
│   ├── theme/                       # AppTheme, colors, typography
│   ├── router/                      # GoRouter configuration
│   ├── constants/                   # App-wide constants
│   ├── errors/                      # FFI error handler, app exceptions
│   └── utils/                       # Shared utilities
├── data/
│   ├── models/                      # Isar schemas (Account, RepoMeta)
│   ├── repositories/                # Data layer abstractions
│   ├── providers/                   # API clients (GitHub, GitLab, Gitea)
│   └── services/
│       ├── git_service.dart         # libgit2dart wrapper
│       ├── auth_service.dart        # OAuth2 flow + secure storage
│       ├── database_service.dart    # Isar lifecycle
│       └── asset_manager.dart       # Lazy-load educational assets
├── features/
│   ├── auth/                        # M1: Multi-Account & Auth
│   │   ├── bloc/
│   │   ├── views/
│   │   └── widgets/
│   ├── repository/                  # M2: Repository Management
│   │   ├── bloc/
│   │   ├── views/
│   │   │   ├── graph_view.dart
│   │   │   ├── staging_view.dart
│   │   │   ├── diff_view.dart
│   │   │   └── conflict_view.dart
│   │   └── widgets/
│   │       ├── commit_graph_painter.dart
│   │       ├── diff_panel.dart
│   │       └── conflict_panel.dart
│   ├── terminal/                    # M3: Terminal
│   │   ├── bloc/
│   │   ├── views/
│   │   └── widgets/
│   └── academy/                     # Educational section
│       ├── bloc/
│       ├── views/
│       └── widgets/
├── onboarding/
│   ├── bloc/
│   ├── tutorial_targets.dart        # CoachMark target definitions
│   └── views/
└── widgets/                         # Shared widgets
    ├── app_scaffold.dart
    ├── account_switcher.dart
    └── loading_overlay.dart
```

---

## Proposed Changes

### Phase 0 — Environment Setup

#### [NEW] Flutter project initialization

- Install Flutter SDK on the system
- Run `flutter create --org com.fluxgit --project-name flux_git --platforms=linux,android .` in workspace
- Enable linux desktop: `flutter config --enable-linux-desktop`

#### [NEW] [pubspec.yaml](file:///home/samuele/Documents/dev/git-client/pubspec.yaml)

Key dependencies with pinned versions:

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^9.1.1 | BLoC state management |
| `git2dart` | ^0.4.0 | libgit2 FFI bindings |
| `git2dart_binaries` | ^1.10.3 | Pre-built libgit2 natives |
| `isar` | ^3.1.0 | Local NoSQL database |
| `isar_flutter_libs` | ^3.1.0 | Isar native libs |
| `flutter_secure_storage` | ^10.0.0 | OAuth2 token storage |
| `tutorial_coach_mark` | ^1.3.3 | Onboarding coach marks |
| `xterm` | ^4.0.0 | Terminal emulator widget |
| `go_router` | ^14.0.0 | Declarative routing |
| `equatable` | ^2.0.5 | Value equality for BLoC |
| `google_fonts` | ^6.0.0 | Typography (Inter/Outfit) |
| `url_launcher` | ^6.2.0 | OAuth redirect handling |
| `http` | ^1.2.0 | REST API calls |
| `flutter_markdown` | ^0.7.0 | Academy Markdown rendering |
| `path_provider` | ^2.1.0 | File system paths |
| `freezed_annotation` | ^2.4.0 | Immutable models |
| `json_annotation` | ^4.9.0 | JSON serialization |

Dev dependencies: `build_runner`, `freezed`, `json_serializable`, `isar_generator`, `flutter_lints`

---

### Phase 1 — Core Foundation & Theme

#### [NEW] [app.dart](file:///home/samuele/Documents/dev/git-client/lib/app.dart)

- `MaterialApp.router` with `GoRouter`
- Dark theme with premium palette (deep navy `#0D1117` background — GitHub-dark inspired)
- Google Fonts `Inter` for body, `JetBrains Mono` for code/diffs

#### [NEW] [core/theme/app_theme.dart](file:///home/samuele/Documents/dev/git-client/lib/core/theme/app_theme.dart)

- `ThemeData` with curated `ColorScheme`: surface `#0D1117`, primary `#58A6FF`, secondary `#3FB950`, error `#F85149`
- Card glassmorphism (blur + translucent backgrounds)
- Consistent border radius, elevation, padding tokens

#### [NEW] [core/router/app_router.dart](file:///home/samuele/Documents/dev/git-client/lib/core/router/app_router.dart)

- Routes: `/onboarding`, `/home`, `/repo/:id`, `/repo/:id/diff`, `/repo/:id/conflicts`, `/terminal`, `/academy`
- Guard: redirect to `/onboarding` if first launch

#### [NEW] [core/errors/ffi_error_handler.dart](file:///home/samuele/Documents/dev/git-client/lib/core/errors/ffi_error_handler.dart)

- Wraps all libgit2dart calls in try/catch
- Maps FFI exceptions to user-friendly `GitOperationFailure` types
- Prevents app crash on corrupted repo

---

### Phase 2 — Multi-Account & Auth (M1)

#### [NEW] [data/models/account.dart](file:///home/samuele/Documents/dev/git-client/lib/data/models/account.dart)

Isar collection schema:
```dart
@collection
class Account {
  Id id = Isar.autoIncrement;
  @enumerated
  late Provider provider;    // github, gitlab, gitea
  late String username;
  late String serverUrl;     // custom for Gitea
  late String avatarUrl;
  late bool skipSslVerify;   // for self-hosted Gitea
  late DateTime addedAt;
}
```

#### [NEW] [data/services/auth_service.dart](file:///home/samuele/Documents/dev/git-client/lib/data/services/auth_service.dart)

- OAuth2 PKCE flow for GitHub/GitLab
- Personal Access Token (PAT) flow for Gitea
- Token storage/retrieval via `flutter_secure_storage`
- Token refresh logic

#### [NEW] [features/auth/bloc/](file:///home/samuele/Documents/dev/git-client/lib/features/auth/bloc/)

- `AuthBloc`: handles `LoginRequested`, `LogoutRequested`, `SwitchAccount` events
- States: `AuthInitial`, `AuthLoading`, `Authenticated(account)`, `AuthError(message)`

#### [NEW] [features/auth/views/login_page.dart](file:///home/samuele/Documents/dev/git-client/lib/features/auth/views/login_page.dart)

- Provider picker (GitHub / GitLab / Gitea cards with logos)
- Gitea: extra fields for custom URL + SSL toggle
- Animated transitions between steps

#### [NEW] [widgets/account_switcher.dart](file:///home/samuele/Documents/dev/git-client/lib/widgets/account_switcher.dart)

- Bottom sheet / dropdown with avatar + username for each saved account
- Active account highlighted, tap to switch

---

### Phase 3 — Repository Management GUI (M2)

#### [NEW] [data/services/git_service.dart](file:///home/samuele/Documents/dev/git-client/lib/data/services/git_service.dart)

Wraps `git2dart` in a clean service layer:
- `clone(url, path, credentials)` → progress stream
- `open(path)` → `Repository`
- `log(repo, {branch, limit})` → `List<Commit>`
- `stage(repo, paths)`, `unstage(repo, paths)`
- `commit(repo, message, author)` 
- `diff(repo, {cached})` → `Diff`
- `branches(repo)`, `createBranch(...)`, `checkout(...)`
- `merge(repo, branch)`, `rebase(repo, onto)`
- `push(repo, remote, credentials)`, `pull(repo, remote, credentials)`
- All methods wrapped through `FfiErrorHandler`

#### [NEW] [features/repository/bloc/repo_bloc.dart](file:///home/samuele/Documents/dev/git-client/lib/features/repository/bloc/repo_bloc.dart)

Events: `LoadRepo`, `StageFiles`, `UnstageFiles`, `CommitChanges`, `SwitchBranch`, `MergeInto`, `RebaseOnto`, `Push`, `Pull`

#### [NEW] [features/repository/widgets/commit_graph_painter.dart](file:///home/samuele/Documents/dev/git-client/lib/features/repository/widgets/commit_graph_painter.dart)

- `CustomPainter` rendering commit DAG
- Color-coded branches, merge lines, HEAD indicator
- Scrollable with `InteractiveViewer`
- Tappable nodes → show commit detail panel

#### [NEW] [features/repository/views/staging_view.dart](file:///home/samuele/Documents/dev/git-client/lib/features/repository/views/staging_view.dart)

- Two-list layout: Unstaged ↔ Staged
- Checkbox + swipe to stage/unstage
- Submodule indicators
- Commit message field + commit button

#### [NEW] [features/repository/views/diff_view.dart](file:///home/samuele/Documents/dev/git-client/lib/features/repository/views/diff_view.dart)

- Side-by-side diff with syntax highlighting
- Line numbers, additions (green), deletions (red)
- File tabs for multi-file diffs

#### [NEW] [features/repository/views/conflict_view.dart](file:///home/samuele/Documents/dev/git-client/lib/features/repository/views/conflict_view.dart)

- Three-pane: **Mine** | **Theirs** | **Merged**
- Clickable conflict markers to accept left/right/both
- Manual edit in Merged pane
- "Mark as Resolved" button per file

---

### Phase 4 — Terminal Emulator (M3)

#### [NEW] [features/terminal/views/terminal_page.dart](file:///home/samuele/Documents/dev/git-client/lib/features/terminal/views/terminal_page.dart)

- `xterm` `TerminalView` widget connected to system shell via `pty` (desktop)
- Theme matching app dark theme
- Git CLI detection: `which git` → full passthrough, else show banner + limited commands via libgit2

#### [NEW] Android Termux integration

- Platform channel to launch `Intent` for `com.termux`
- Fallback: display "Install Termux" prompt

---

### Phase 5 — Onboarding & Academy

#### [NEW] [onboarding/tutorial_targets.dart](file:///home/samuele/Documents/dev/git-client/lib/onboarding/tutorial_targets.dart)

- `TargetFocus` list for: add-account button, branch graph, staging area, terminal tab
- `tutorial_coach_mark` overlay with animated pulsing

#### [NEW] Skill-level modal

- First-launch dialog: Beginner / Intermediate / Advanced
- Persisted in Isar `UserPreferences`
- Controls visibility of Academy hints & simplified labels

#### [NEW] [features/academy/](file:///home/samuele/Documents/dev/git-client/lib/features/academy/)

- Markdown-based pages: "What is a Commit?", "Merge vs Rebase", "Branching Strategies"
- `AssetManager` service to lazy-load GIF/image assets from `assets/academy/`
- `flutter_markdown` renderer with custom image builder for bundled assets

---

## Verification Plan

### Automated Tests

Since this is a greenfield project, we'll create tests as we build each module:

1. **Unit tests for BLoC layer** (`test/features/auth/bloc/auth_bloc_test.dart`, etc.)
   - Command: `flutter test test/features/auth/`
   - Verify state transitions: `AuthInitial` → `AuthLoading` → `Authenticated`

2. **Unit tests for GitService** (`test/data/services/git_service_test.dart`)
   - Command: `flutter test test/data/services/`
   - Create temporary repos, test clone/commit/branch/diff operations

3. **Widget tests** (`test/features/repository/widgets/`)
   - Command: `flutter test test/features/repository/`
   - Verify commit graph renders, diff view shows correct colors

4. **Build verification**
   - Command: `flutter build linux` — must complete without errors
   - Command: `flutter analyze` — zero issues

### Manual Verification

1. **Launch the app** on Linux desktop → verify dark theme loads, navigation works
2. **Add a GitHub account** → OAuth flow completes, token stored, account appears in switcher
3. **Clone a public repo** → progress shown, repo opens in graph view
4. **Make a change → stage → commit** → verify in terminal with `git log`
5. **View diff** → side-by-side shows additions/deletions correctly
6. **Open terminal** → shell prompt appears, `git status` works

> [!TIP]
> I will run `flutter test` and `flutter analyze` after each phase to catch regressions early.
