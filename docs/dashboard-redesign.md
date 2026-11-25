# Dashboard redesign

The redesigned Pet Health Tracker uses the same Flutter routes, controllers, and
SQLite data on web, Windows, Android, iOS, and macOS. The dashboard takes its
visual cues from the supplied reference, including off-white surfaces, muted teal,
status-tinted metrics, compact panels, and a branded navigation rail.

## What changed

- The wide dashboard puts today's date and the household greeting above a summary
  of pets, vaccination status, and visits this week. Overdue and due-soon tiles
  count pets by their most urgent tracked vaccination. The due-soon window
  follows Profile settings. Visits count scheduled and completed appointments
  by their scheduled date in the current local Monday–Sunday week.
- Quick log uses the selected pet and the existing instant-log, undo, and full
  journal forms. Pet rows and the attention panel open the same pet detail page.
  The visits and recent journal panels link to their full sections.
- Profile anchors at the bottom of the wide navigation. The active item has a
  teal highlight and icon-only destinations show accessible tooltips.
- Journal groups, Profile settings, and dashboard sections share a bordered
  panel style. Page gutters, input borders, focus feedback, typography, status
  colors, and motion are defined centrally.
- Phone layouts retain the bottom navigation, pet carousel, portrait detail
  sheet, and touch interactions. A compact summary follows the existing Home
  content on phones.

## How it adapts

| Logical width | Navigation | Content |
| --- | --- | --- |
| Below 640 px | Bottom bar and raised Quick actions button | Phone layout with touch forms and a compact summary |
| 640–1023 px | 72 px icon rail | Constrained body and centered dialogs. Panels stack when their content area is narrow |
| 1024–1279 px | 72 px rail by default. Expand manually | Dashboard and appointment columns reflow around the sidebar |
| 1280–1535 px | 232 px expanded sidebar by default. Collapse manually | More room for side-by-side panels and grouped lists |
| 1536 px and above | Same expanded sidebar and manual toggle | Wider gutters with the content capped at 1380 px |

`AppLayout` reads logical width from `MediaQuery`. `LayoutBuilder` checks how
much space is left after navigation and padding. The dashboard summary fits
four, two, or one tile per row and also considers text scale. Wider pages use
`PageContent` and `AdaptiveColumns` to cap line length and reflow each panel.
The same `StatefulShellRoute.indexedStack` stays mounted across width changes.
An open form retains its current route and inputs during resize, and newly
opened forms use the current width.

Use **Tab** and **Shift+Tab** to move between controls, **Alt+1–4** to switch
sections, **Ctrl+N** or **Cmd+N** for Quick actions, and **Esc** to dismiss a
dialog. Browser and system shortcuts may take precedence. Sidebar and route
animation respect Flutter's reduced-motion setting.

## Run it

From the extracted project root, use Flutter 3.47.5 with Dart 3.13.4.

```sh
flutter pub get
flutter run -d chrome
flutter run -d windows
```

Use the Windows command on a Windows machine with Visual Studio's **Desktop
development with C++** workload. For a phone or emulator, run `flutter devices`
and use the reported device ID in `flutter run -d DEVICE_ID`. The redesign
introduces no package dependencies. See the [README](../README.md) for platform
setup and release build commands.

## Files in this redesign

| Area | Changes |
| --- | --- |
| Navigation | Modified `lib/app/shell/app_shell.dart` and `lib/app/shell/wide_navigation.dart` |
| Dashboard data | Modified `lib/domain/dashboard.dart` and `lib/data/sqlite/sqlite_dashboard_repository.dart` |
| Home and summary | Modified `lib/features/home/home_screen.dart` and `lib/features/home/widgets/next_appointment_card.dart`. Added `lib/features/home/widgets/dashboard_summary.dart` |
| Other pages | Modified `lib/features/appointments/appointments_screen.dart`, `lib/features/journal/journal_screen.dart`, `lib/features/profile/profile_screen.dart`, `lib/features/pets/pet_detail_screen.dart`, and `lib/features/pets/pet_routes.dart` |
| Design system | Modified `lib/ui/theme/app_theme.dart`, `lib/ui/layout/adaptive_layout.dart`, `lib/ui/format/app_formats.dart`, `lib/ui/kit/app_card.dart`, `lib/ui/kit/app_chip.dart`, `lib/ui/kit/empty_state.dart`, and `web/manifest.json`. Added `lib/ui/kit/workspace_panel.dart` |
| Tests | Modified `test/app/adaptive_app_test.dart`, `test/data/repositories_test.dart`, and `test/features/journal/journal_screen_test.dart` |
| Docs | Modified `AGENTS.md`, `README.md`, and `docs/adaptive-desktop.md`. Added `docs/dashboard-redesign.md` and screenshots in `docs/previews/` |

## Screenshots

The screenshots use the built-in sample household.

| Preview | Viewport |
| --- | --- |
| [Desktop dashboard](previews/dashboard-desktop.png) | 1440 × 900 |
| [Tablet dashboard](previews/dashboard-tablet.png) | 768 × 1024 |
| [Phone Home](previews/dashboard-phone.png) | 390 × 844 |
| [Desktop journal](previews/journal-desktop.png) | 1440 × 900 |
| [Desktop Quick actions](previews/quick-actions-desktop.png) | 1440 × 900 |

## Verification

| Check | Result |
| --- | --- |
| `flutter analyze --no-pub` | Zero issues |
| `flutter test --no-pub --reporter expanded` | 201 VM tests, including the checkout's SQLite repository and widget suites |
| `flutter build web --release --no-pub --no-web-resources-cdn` | Release build succeeded |
| Requested viewports | 375 × 812, 390 × 844, 768 × 1024, 1024 × 768, 1280 × 720, 1366 × 768, 1440 × 900, 1920 × 1080, and 2560 × 1440 exercised in Flutter widgets and Chromium |
| Extra resize coverage | Intermediate widths around 640, 1024, 1280, and 1536 px, a short 820 × 390 viewport, and a rapid sequence of resizes that crosses the navigation breakpoints |
| Chromium release smoke test | Verified sidebar collapse and expansion, all four sections, journal filtering across resize, a booking draft through resize, saving the visit, and finding it again after an IndexedDB reload. The checked viewports had no horizontal page scroll |
| Standalone `flutter test --platform chrome test/web/web_boot_test.dart` | The runner did not initially serve the SQLite WebAssembly asset. It timed out after the file was staged at the requested test path. The release build served SQLite normally in Chromium |
| Native devices | Native Windows builds and file picking still need a Windows machine. Android, iOS, and macOS device launches, OS window tiling, and browser-specific zoom controls were outside the environment used here |
