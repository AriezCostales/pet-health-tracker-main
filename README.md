# Pet Health Tracker

An offline pet health and vet appointment tracker for one household:
one owner, several pets, a shared journal, vet visits, vaccinations and
append-only clinical notes. No accounts, no network, no backend — the SQLite
database on the device is the only source of truth.

| Destination | What it does |
| --- | --- |
| **Home / Dashboard** | Household summary, quick log, pets, vaccination attention, upcoming visits, and recent journal entries. On phones, the swipeable pet cards, quick log, and recent activity serve as the household summary. |
| **Journal** | The household feed, newest first, grouped Today / Yesterday / full date, with a per-pet filter. Tap a row to edit its time, note and duration, or delete it. |
| **Appointments** | Upcoming / Past toggle with a per-pet filter. Tap a visit to complete it, cancel it with a reason, mark a no-show (only after the scheduled time), reschedule it, or jump to that pet's filtered list. |
| **Profile** | Owner details (editable), the pet list, and four settings rows: due-soon window, weight unit, the sample-data toggle and Reset household. |
| **Pet page** | A full-page photo (or drawn portrait) with a two-stop sheet: resting shows the name, worst due status and the vaccine that needs attention; raised reveals every vaccine and the append-only medical history. Reached by tapping a Home pet card or a Profile pet row. |
| **Welcome** | First-run onboarding for an empty household: your name, your first pet, or one tap to start with the sample household. |

Use the raised centre button on phones or **Quick actions** in the wide toolbar
to book a vet visit, log an entry, or add a health record. Tablet and desktop
layouts use a workspace sidebar, wider lists, and dialogs. See the
[redesign notes](docs/dashboard-redesign.md) for screenshots, the responsive
layout, the files changed, and verification. The
[desktop implementation notes](docs/adaptive-desktop.md) explain the Windows
runner and local storage.

## Running it

Install Flutter **3.47.5 stable** (Dart **3.13.4**) and open a terminal at the
extracted project root, where `pubspec.yaml` is located.

```sh
flutter doctor -v
flutter pub get
flutter devices
```

### Windows desktop

On Windows, install Visual Studio with the **Desktop development with C++**
workload, including the Windows SDK and CMake tools. This is distinct from
Visual Studio Code. Check for a Windows device in `flutter devices`. If needed,
run `flutter config --enable-windows-desktop`.

```powershell
flutter run -d windows
flutter build windows --release
```

For distribution, copy the full release output folder, typically
`build/windows/x64/runner/Release/`. Keep its executable, DLLs, and `data/`
directory together. Windows stores household data in the user's Application
Support directory under Roaming AppData, separate from the executable.
`sqflite_common_ffi` uses SQLite build hooks to bundle the native library.
The first build needs network access for packages and native build artifacts.

### Android, iOS, macOS, and web

Install Android Studio and its SDK for Android, or Xcode on macOS for iOS and
macOS. Start an emulator, run a simulator, or connect a phone and use the device
ID shown by `flutter devices`.

```sh
flutter run -d <device-id>
flutter run -d macos       # on macOS
flutter run -d chrome      # browser, including the wide layout
```

**iPhone**, one extra pass — the bundle identifier in this repository belongs to
its original author, so your build cannot claim it:

1. `open ios/Runner.xcworkspace`
2. Runner → **Signing & Capabilities** → set **Team** to your Apple ID (free is fine)
3. Change **Bundle Identifier** to something of your own, e.g. `com.yourname.petHealthTracker`
4. `flutter run`, then on the phone: Settings → General → VPN & Device Management → **Trust**

**Android** needs nothing extra: debug builds sign themselves.

### On the machine this was developed on

Flutter runs through a wrapper that keeps the SDK cache and pub state inside the
workspace:

```bash
./tool/fv pub get
./tool/fv devices
xcrun simctl boot "iPhone 17 Pro"      # or attach a phone
./tool/fv run -d "iPhone 17 Pro"
```

`./tool/fv` falls back to whatever `flutter` is on `PATH` when `.flutter-sdk/` is
absent, so a clone without the sandbox SDK still works. Do not copy
`.flutter-sdk/`, `.pub-cache/` or `.tool-home/` between machines — they are
gitignored workspace artifacts; see [`tool/README.md`](tool/README.md).

## Publishing it for other people

Two different things people can mean by "try my app":

| Audience | Give them | They need |
| --- | --- | --- |
| Friends who just want to use it in a browser | The **Pages URL** (or a zip of `build/web`) | Nothing — a browser |
| Friends who want to run it from source | The **repository** | Flutter + `flutter run -d chrome` |

GitHub Pages is automated: `.github/workflows/deploy-web.yml` builds the web
bundle on every push to `main` and publishes it. Enable it once under
**Settings → Pages → Source: GitHub Actions**, and the app will be at
`https://<you>.github.io/<repo>/`.

To build the bundle yourself:

```bash
flutter build web --release --base-href "/<repo>/"
# then serve build/web from any static server
```

The `--base-href` matters: without it the bundle assumes it is served from the
domain root, and the app loads a blank page under a repository path. A lone
`index.html` opened from `file://` will not work either — Flutter web needs an
HTTP server.

On the web the app stores its database in the browser's IndexedDB, so every
visitor gets their own household, and clearing site data resets it. Pet photos
are not available in the browser; the drawn portrait is used instead.

## First launch

The app creates `pet_health_tracker.db`, the household owner row and the vaccine
catalog.

- **Sample data is off by default**, so a fresh install opens on the **Welcome**
  card: name yourself, add your first pet, or tap *start with the sample
  household* to get Bella and Miso instead.
- **With the sample data on** — from the Welcome card or `Profile → Sample data` —
  the app seeds the demo household and Home opens with something to look at.

The demo household is a fixed list of row ids (see `demoPetIds` and friends in
`lib/data/seed/sample_data_service.dart`), so `Profile → Sample data` can remove
and restore it without touching anything the owner typed. It is deliberately not
an id *range*: these tables are `AUTOINCREMENT`, so the owner's own rows land
above 9000 after seeding.

## Demo household

- **Bella** — dog, Golden Retriever mix, 12.4 kg, rabies booster **overdue** by 35
  days, DHPP up to date, one clinical note (ear infection).
- **Miso** — cat, Domestic shorthair, 4.2 kg, FeLV **due soon** (10 days), FVRCP
  up to date, one clinical note (annual exam).
- Four journal entries across the last five days (walk, feeding, note, symptom).
- One upcoming visit (Bella, annual wellness check) and one completed visit
  (Miso, dental cleaning).

Dates are relative to the day the demo is seeded, so a rehearsal weeks later still
shows a current household. `Profile → Sample data` is the only toggle: off deletes
the demo rows, on reseeds them, and the choice persists across restarts.

## Tests and checks

```bash
./tool/fv analyze                        # static analysis, must be clean
./tool/fv test                           # full native unit and widget suite
./tool/fv test test/app                  # router / shell boot
./tool/fv test test/features/home        # one feature area
./tool/format --set-exit-if-changed lib test
sqlite3 :memory: ".read db/schema.sql"   # DDL smoke test
```

The widget tests boot the real app — router, shell, real screens — against a real
SQLite database through `sqflite_common_ffi`, applying the shipped
`db/schema.sql`. Coverage: the navigation shell, quick logging and its undo
timeout, the journal filter, the pet page and its sheets, appointment transitions
and same-day collisions, the demo-id ownership rule, vaccination superseding, the
local calendar day, profile settings, the demo seed, and live window resizing.
Widget tests exercise the same form handlers used by mobile sheets and wide dialogs.

Screenshots of the running app can be regenerated without a device:

```bash
./tool/fv test --update-goldens test/shots/shot_harness.dart   # → test/shots/*.png
```

## Gestures and shortcuts

- **Centre `+`** — book a visit, log an entry, add a health record.
- **Quick-log chip** — tap saves that kind at the current moment; the confirmation
  offers Undo for three seconds. **Long-press** opens the full form (date, time,
  note, duration).
- **Home appointment card** — opens that visit's actions sheet; inside it,
  *View in Appointments* switches tabs filtered to that pet.
- **Home owner avatar** — opens Profile with the section fade.
- **Home recent row** — opens the same edit sheet the Journal uses.
- **Pet card / Profile pet row** — open the pet page.
- **Sheet handle** — tap or drag to raise the pet page's sheet.
- **Pull down** on Home, Journal or Appointments to reload.

While `./tool/fv run` (or `flutter run`) is attached: `r` hot reload, `R` hot
restart, `q` quit.

## Project layout

| Path | Contents |
| --- | --- |
| `lib/app/` | composition root (`di.dart`, `app_services.dart`), router, shell, `AppSettings`, `AppScope`, cross-screen navigation requests |
| `lib/domain/` | immutable models and pure rules — no Flutter, no SQL, no `dart:io` |
| `lib/data/` | SQLite bootstrap, mappers, repositories, seeding, settings store, pet photos — all SQL lives here |
| `lib/ui/` | theme tokens, presentation-only kit, `intl` format helpers |
| `lib/features/<area>/` | home, journal, appointments, pets, profile, onboarding |
| `db/schema.sql` | the DDL contract, applied verbatim on first launch |
| `test/` | domain, data (real FFI SQLite), app boot, feature widget tests |
| `docs/` | demo and rehearsal material |
| `tool/` | the sandbox-safe Flutter/Dart wrappers |

[`AGENTS.md`](AGENTS.md) is the implementation contract: dependency rules, the
domain/data API, conventions and the definition of done.

## Data and storage

- One SQLite file (`pet_health_tracker.db`) in the platform database directory,
  created from `db/schema.sql`; `settings.json` and a `pet_photos/` folder sit
  next to it.
- Pet photos are copied into `pet_photos/` rather than referenced in place: iOS
  and Android both hand back temporary files that the system may delete. A
  replaced or removed photo is deleted after the form saves.
- Date-only columns are `YYYY-MM-DD`; instants are ISO-8601 UTC. The app formats
  them for the device zone with `intl`.
- Clinical notes (`health_record`) are append-only: the schema's triggers reject
  updates and deletes, and the UI offers no edit or delete affordance.
- Journal entries stay editable. Deleting a pet removes its journal, vaccination
  and clinical rows and leaves its appointments under the household.

## Troubleshooting

Any machine:

| Symptom | Cause | Fix |
| --- | --- | --- |
| `No supported devices` | Nothing booted or attached | Start the emulator / connect the phone; `flutter devices` |
| `No Android SDK found` | Android Studio missing | Install it, then `flutter doctor --android-licenses` |
| *Failed to register bundle identifier* | The id is registered to someone else | Change it in Signing & Capabilities |
| App refuses to open on iPhone | Developer certificate untrusted | Settings → General → VPN & Device Management → Trust |
| Windows missing from `flutter devices` | Windows desktop is disabled or the Windows toolchain is missing | Enable Windows desktop and check the Visual Studio workload with `flutter doctor -v` |

On the original development machine only:

- Always use `./tool/fv` there, never a bare `flutter`/`dart`: the wrappers keep
  the SDK cache inside the workspace, which the sandbox requires.
- `xcodebuild` permission errors under `~/Library` mean the process cannot write
  outside the repository. Launch from a normal terminal, or set
  `FV_REAL_HOME=1` so Xcode's account store and DerivedData stay in the real home.
