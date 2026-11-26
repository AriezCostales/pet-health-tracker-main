# Adaptive desktop implementation

## Project audit

| Area | Source architecture and adaptation |
| --- | --- |
| App startup and navigation | `main.dart` boots `AppServices` before building the widget tree. `go_router` uses four retained branches in a `StatefulShellRoute.indexedStack`. Pet details keep their own route. The browser's fixed 390 px phone frame has been replaced by width-aware navigation in the same router. |
| State and actions | Feature `ChangeNotifier` controllers receive services through `AppScope`. The same controllers, validation rules, write handlers, and refresh notifications serve all viewport sizes. |
| Database | The existing seven-table SQLite schema, repositories, demo seeding, and data migration version continue to serve all platforms. Windows adds a native SQLite FFI factory. Browser storage uses the shipped WASM asset and IndexedDB. Native settings and pet photos live beside the SQLite file. |
| Accounts and integrations | The app tracks one local household. The Profile editor manages owner details. There is no authentication service, API, or backend. |
| Theme and assets | Material 3 theme tokens provide the paper, surface, teal accent, typography, status colors, and shared cards, chips, and buttons. Pet photos come from local gallery or file selection. The app uses Material icons and its existing platform icon assets. |

## Window behavior

Desktop builds and desktop browsers keep the desktop dashboard at every width.
The sidebar compacts as space shrinks and moves into a toolbar drawer below
640 logical pixels. Android and iOS use mobile Home with bottom navigation.
The underlying routes, controllers, and local SQLite storage are shared.

The desktop Home quick-log panel logs against the selected pet. Use its
edit-note menu to open the full journal form. Appointments and Journal expose
refresh controls for mouse users. The desktop pet detail shows vaccines and
clinical notes in scrollable panels.

The router retains the selected section and form inputs when a desktop window
resizes. Desktop forms use dialogs and mobile forms use bottom sheets. See the
[dashboard redesign](dashboard-redesign.md) for breakpoints and shortcuts.

## Windows and data

The Windows runner starts at 1280 × 800 logical pixels and uses the
**Pet Health Tracker** window title. Run it with Flutter 3.47.5 and Visual Studio's
**Desktop development with C++** workload. The existing FFI SQLite dependency
is now available at runtime, and the existing Windows path-provider package is
declared directly. The lockfile keeps both at the versions already used by the
project. The first build downloads the SQLite native asset through the package's
build hook. The Windows CMake build disables optional JVM discovery for the
transitive JNI plugin, which the app only uses through its Android packages.

On Windows, the application support path is typically
`%APPDATA%\Pet Health Tracker`. It contains
`pet_health_tracker.db`, `settings.json`, and the optional `pet_photos/`
directory. Android, iOS, and macOS use their existing native database
directories. Browser data is scoped to its origin. Each installation has its
own local data. The existing browser photo fallback continues to display a
drawn portrait.

## Files

| Change | Paths |
| --- | --- |
| Added shared layout and navigation | `lib/ui/layout/adaptive_layout.dart`, `lib/app/shell/shell_destinations.dart`, `lib/app/shell/wide_navigation.dart` |
| Adapted the app and forms | `lib/app/app.dart`, `lib/app/router.dart`, `lib/app/shell/app_shell.dart`, `lib/app/shell/centre_action_sheet.dart`, `lib/ui/kit/app_sheet.dart` |
| Adapted feature screens and forms | `lib/features/home/home_screen.dart`, `lib/features/home/widgets/quick_log_row.dart`, `lib/features/journal/journal_screen.dart`, `lib/features/appointments/appointments_screen.dart`, `lib/features/profile/profile_screen.dart`, `lib/features/profile/owner_form_sheet.dart`, `lib/features/pets/pet_detail_screen.dart`, `lib/features/pets/pet_routes.dart`, `lib/features/pets/pet_chooser_sheet.dart`, `lib/features/pets/forms/pet_form_sheet.dart` |
| Adapted native storage | `lib/platform/platform_database_io.dart`, `lib/data/pet_photos_io.dart`, `pubspec.yaml`, `pubspec.lock` |
| Added the Windows runner | All files in `windows/`, including CMake configuration, the C++ runner and resources, and generated plugin registration files |
| Registered the platform and updated browser metadata | `.metadata`, `analysis_options.yaml`, `web/index.html`, `web/manifest.json` |
| Added resize regressions and pinned the existing mobile shell tests to a phone viewport | `test/app/adaptive_app_test.dart` (new), `test/app/app_boot_test.dart` |
| Updated documentation | `README.md`, `AGENTS.md`, `docs/adaptive-desktop.md` (new) |
| Removed | `lib/app/phone_frame.dart`. The source archive also omits the original broken local SDK and package-cache symlinks. |

### Windows files added

- `windows/.gitignore`
- `windows/CMakeLists.txt`
- `windows/flutter/CMakeLists.txt`
- `windows/flutter/generated_plugin_registrant.cc`
- `windows/flutter/generated_plugin_registrant.h`
- `windows/flutter/generated_plugins.cmake`
- `windows/runner/CMakeLists.txt`
- `windows/runner/Runner.rc`
- `windows/runner/flutter_window.cpp`
- `windows/runner/flutter_window.h`
- `windows/runner/main.cpp`
- `windows/runner/resource.h`
- `windows/runner/resources/app_icon.ico`
- `windows/runner/runner.exe.manifest`
- `windows/runner/utils.cpp`
- `windows/runner/utils.h`
- `windows/runner/win32_window.cpp`
- `windows/runner/win32_window.h`

## Original desktop implementation verification

The [dashboard redesign notes](dashboard-redesign.md) record the latest
verification and screenshot sizes.

| Check | Result |
| --- | --- |
| Flutter 3.47.5 analysis | `flutter analyze --no-pub` reported zero issues. |
| Flutter VM tests | `flutter test --no-pub` passed all 198 tests, including six adaptive widget tests. Existing tests cover the shipped schema, repositories, mobile navigation, pet and owner forms, journal editing, quick actions, settings, and appointment transitions. |
| Adaptive tests | Covered breakpoint transitions, sidebar collapse, active journal filters, keyboard navigation and dialog dismissal, a booking draft surviving resize and saving, wide pet history, narrow pet detail, deep-link back navigation, quick logging for the selected pet, and owner form reflow. |
| Web build | `flutter build web --release --no-pub --no-web-resources-cdn` completed. |
| Chromium smoke test | Verified welcome screen, sample data, quick-action dialog and Escape dismissal, live resizing across both breakpoints, and IndexedDB persistence after reload. |
| Native devices | Windows compilation, first launch, and file picker behavior still need a Windows machine. Android, iOS, and macOS were covered here through shared Flutter code and VM tests. Their native runners were not executed. |
