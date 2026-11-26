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
  sheet, and touch interactions. Home itself serves as the mobile summary.

## How it adapts

The host platform selects the Flutter layout. Desktop browsers and native
desktop builds use the desktop dashboard. Android and iOS devices use the
mobile layout, including their browsers when Flutter identifies the mobile
host platform.

| Desktop window width | Navigation |
| --- | --- |
| Below 640 px | The desktop toolbar opens a navigation drawer |
| 640–1023 px | 72 px icon rail |
| 1024–1279 px | Icon rail by default, with a manual expansion option |
| 1280 px and above | 232 px expanded sidebar by default, with a manual collapse option |

At 1536 px the desktop layout uses wider gutters. The content is capped at
1380 px. `LayoutBuilder` uses the actual available width to reflow cards and
panels. The router and controllers stay mounted, so navigation, filters, and
form drafts survive resizing.

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

## Previous redesign screenshots

The images in `previews/` illustrate the original dashboard redesign. They
predate the platform-specific layout changes described above.

## Layout revision verification

Flutter 3.47.5 analysis reported zero issues and all 202 VM tests passed.
The tests cover desktop resizing, drawer navigation, retained filters and
booking drafts, and bottom navigation without an extra summary on mobile.
The web release build succeeded and Chromium verified desktop navigation
and route retention across a live resize. Native devices were not run.
