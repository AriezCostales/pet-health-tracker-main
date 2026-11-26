import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_health_tracker/app/app.dart';
import 'package:pet_health_tracker/app/shell/app_shell.dart';
import 'package:pet_health_tracker/app/shell/wide_navigation.dart';
import 'package:pet_health_tracker/domain/models/journal_entry.dart';
import 'package:pet_health_tracker/features/pets/pet_routes.dart';
import 'package:pet_health_tracker/features/home/widgets/dashboard_summary.dart';
import 'package:pet_health_tracker/ui/layout/adaptive_layout.dart';
import 'package:pet_health_tracker/ui/theme/app_theme.dart';
import 'package:pet_health_tracker/ui/kit/app_chip.dart';

import '../data/test_support.dart';
import '../features/pets/test_harness.dart';

Finder byKey(String key) => find.byKey(ValueKey<String>(key));

Future<void> resize(WidgetTester tester, double width, {double height = 820}) {
  tester.view.physicalSize = Size(width, height);
  return tester.pumpAndSettle();
}

Future<void> chord(
  WidgetTester tester,
  LogicalKeyboardKey modifier,
  LogicalKeyboardKey key,
) async {
  await tester.sendKeyDownEvent(modifier);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(modifier);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SqliteHarness harness;

  setUp(() async {
    harness = await openHarness(seedDemo: true, inMemory: true);
  });
  tearDown(() => harness.dispose());

  Future<void> boot(WidgetTester tester, {String? location}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 820);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      PetHealthTrackerApp(
        services: harness.services,
        initialLocation: location,
      ),
    );
    await settleAsync(tester);
    await tester.pumpAndSettle();
  }

  void desktopTest(String description, WidgetTesterCallback callback) {
    testWidgets(
      description,
      callback,
      variant: TargetPlatformVariant(<TargetPlatform>{TargetPlatform.windows}),
    );
  }

  testWidgets('mobile Home has no extra summary at phone or tablet widths', (
    WidgetTester tester,
  ) async {
    await boot(tester);
    for (final double width in <double>[390, 768, 1280]) {
      await resize(tester, width);
      expect(find.byType(AppShellBar), findsOneWidget);
      expect(find.byType(WorkspaceBar), findsNothing);
      expect(find.byType(DashboardSummary), findsNothing);
      expect(byKey('pet-card-9001'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    await resize(tester, 390, height: 650);
    final Finder homeList = find.byKey(
      const PageStorageKey<String>('home-scroll'),
    );
    await tester.fling(homeList, const Offset(0, -700), 2000);
    await tester.pumpAndSettle();
    expect(find.text('HOUSEHOLD SUMMARY'), findsNothing);
    expect(find.byType(DashboardSummary), findsNothing);
  });

  desktopTest(
    'shell reflows at both breakpoints and keeps the journal filter',
    (WidgetTester tester) async {
      await boot(tester);
      expect(find.byType(WorkspaceBar), findsOneWidget);
      expect(tester.getTopLeft(find.byType(WideNavigation)).dy, 0);
      expect(tester.getSize(find.byType(WideNavigation)).height, 820);
      expect(find.byType(AppShellBar), findsNothing);
      expect(
        tester.getSize(find.byType(WideNavigation)).width,
        WideNavigation.expandedWidth,
      );

      await tester.tap(byKey('toggle-sidebar'));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(WideNavigation)).width,
        WideNavigation.compactWidth,
      );
      await tester.tap(byKey('toggle-sidebar'));
      await tester.pumpAndSettle();

      await tester.tap(byKey('tab-journal'));
      await settleAsync(tester);
      await tester.pumpAndSettle();
      final Finder bella = byKey('journal-pet-filter-9001');
      await tester.tap(bella);
      await settleAsync(tester);

      for (final double width in <double>[
        1536,
        1280,
        1279,
        1024,
        1023,
        640,
        639,
        390,
        1200,
      ]) {
        await resize(tester, width);
        expect(find.byType(AppShellBar), findsNothing);
        expect(find.byType(WorkspaceBar), findsOneWidget);
        expect(
          byKey('open-desktop-navigation'),
          width < AppLayout.sidebarMinWidth ? findsOneWidget : findsNothing,
        );
        expect(
          byKey('toggle-sidebar'),
          width >= AppLayout.sidebarToggleMinWidth
              ? findsOneWidget
              : findsNothing,
        );
        expect(tester.widget<AppChip>(bella).selected, isTrue);
        expect(byKey('journal-list'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'width $width');
      }

      await resize(tester, 390);
      await tester.tap(byKey('open-desktop-navigation'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer).hitTestable(), findsOneWidget);
      await tester.tap(byKey('tab-appointments'));
      await settleAsync(tester);
      await tester.pumpAndSettle();
      expect(byKey('appointments-list'), findsOneWidget);
      expect(find.byType(Drawer).hitTestable(), findsNothing);
      await tester.tap(byKey('open-dashboard'));
      await settleAsync(tester);
      await tester.pumpAndSettle();
      expect(find.byType(DashboardSummary), findsOneWidget);
    },
  );

  desktopTest('scheduled badges are aligned in a narrow appointment view', (
    WidgetTester tester,
  ) async {
    await boot(tester);
    await resize(tester, 492);
    await chord(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.digit3);
    await settleAsync(tester);
    await tester.pumpAndSettle();
    final Finder card = byKey('appointment-card-9301');
    final Finder badge = find.descendant(
      of: card,
      matching: find.byType(AppChip),
    );
    expect(tester.getCenter(badge).dy, closeTo(tester.getCenter(card).dy, 1));

    await tester.tap(card);
    await tester.pumpAndSettle();
    final Finder dialog = find.byType(Dialog);
    final Finder label = find.descendant(
      of: dialog,
      matching: find.text('VISIT'),
    );
    final Finder dialogBadge = find.descendant(
      of: dialog,
      matching: find.byType(AppChip),
    );
    expect(
      tester.getCenter(dialogBadge).dy,
      closeTo(tester.getCenter(label).dy, 1),
    );
    final Finder dialogSurface = find
        .descendant(of: dialog, matching: find.byType(Material))
        .first;
    expect(
      tester.getTopLeft(dialogBadge).dy - tester.getTopLeft(dialogSurface).dy,
      AppSpacing.lg,
    );
    expect(tester.takeException(), isNull);
  });

  desktopTest('keyboard navigation and booking dialog survive a live resize', (
    WidgetTester tester,
  ) async {
    await boot(tester);
    await chord(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.digit3);
    await settleAsync(tester);
    await tester.pumpAndSettle();
    expect(byKey('appointments-list'), findsOneWidget);

    await chord(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyN,
    );
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);

    await tester.tap(byKey('centre-action'));
    await tester.pumpAndSettle();
    await tester.tap(byKey('centre-action-book'));
    await settleAsync(tester);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await tester.enterText(byKey('appointment-form-clinic'), 'City Vet');
    await tester.enterText(byKey('appointment-form-purpose'), 'Booster shot');

    await resize(tester, 390, height: 650);
    expect(find.text('City Vet'), findsOneWidget);
    final Finder save = byKey('appointment-form-save');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await settleAsync(tester);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('City Vet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  desktopTest('desktop pet history stays visible when the window narrows', (
    WidgetTester tester,
  ) async {
    await boot(tester);
    await tester.tap(byKey('pet-card-9001'));
    await settleAsync(tester);
    await tester.pumpAndSettle();
    expect(byKey('vaccines-section'), findsOneWidget);
    expect(byKey('medical-history-section'), findsOneWidget);
    expect(byKey('pet-swipe-hint'), findsNothing);

    await resize(tester, 390);
    expect(byKey('pet-sheet'), findsNothing);
    expect(byKey('medical-history-section'), findsOneWidget);
    await tester.tap(byKey('pet-back'));
    await settleAsync(tester);
    await tester.pumpAndSettle();
    expect(byKey('pet-card-9001'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  desktopTest('a short, wide pet deep link can return to Home', (
    WidgetTester tester,
  ) async {
    await boot(
      tester,
      location: PetRoutes.detailPath.replaceFirst(':petId', '9001'),
    );
    await resize(tester, 1050, height: 420);
    expect(byKey('pet-name'), findsOneWidget);
    await tester.tap(byKey('pet-back'));
    await settleAsync(tester);
    await tester.pumpAndSettle();
    expect(find.text('Needs attention'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  desktopTest('dashboard metrics group into four or two columns', (
    WidgetTester tester,
  ) async {
    await boot(tester);
    final Finder pets = find.text('Pets');
    final Finder overdue = find.text('Pets overdue');
    final Finder soon = find.text('Pets due soon');
    expect(tester.getTopLeft(pets).dy, tester.getTopLeft(soon).dy);
    expect(tester.getTopLeft(pets).dx, lessThan(tester.getTopLeft(soon).dx));
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));

    await resize(tester, 768, height: 1024);
    expect(tester.getTopLeft(pets).dy, tester.getTopLeft(overdue).dy);
    expect(tester.getTopLeft(soon).dx, tester.getTopLeft(pets).dx);
    expect(tester.getTopLeft(soon).dy, greaterThan(tester.getTopLeft(pets).dy));
    expect(tester.takeException(), isNull);
  });

  desktopTest('dashboard fits the requested windows without layout errors', (
    WidgetTester tester,
  ) async {
    await boot(tester);
    const List<Size> windows = <Size>[
      Size(375, 812),
      Size(390, 844),
      Size(768, 1024),
      Size(1024, 768),
      Size(1280, 720),
      Size(1366, 768),
      Size(1440, 900),
      Size(1920, 1080),
      Size(2560, 1440),
      Size(820, 390),
    ];
    for (final Size window in windows) {
      await resize(tester, window.width, height: window.height);
      expect(tester.takeException(), isNull, reason: '$window');
      expect(find.byType(WorkspaceBar), findsOneWidget);
      expect(find.byType(AppShellBar), findsNothing);
    }
  });

  desktopTest('desktop quick log writes to the selected pet', (
    WidgetTester tester,
  ) async {
    await boot(tester);
    final Finder petMenu = find.byType(DropdownMenu<int>);
    await tester.ensureVisible(petMenu);
    await tester.tap(petMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Miso'));
    await tester.pumpAndSettle();
    await tester.tap(byKey('quick-log-walk'));
    await settleAsync(tester);

    final List<JournalEntry> entries = await databaseResult(
      tester,
      () => harness.services.journal.listForPet(9002),
    );
    expect(entries.first.kind, JournalKind.walk);
    expect(entries.first.petId, 9002);
    expect(tester.takeException(), isNull);
  });

  desktopTest('profile settings and owner form use desktop columns', (
    WidgetTester tester,
  ) async {
    await boot(tester);
    await tester.tap(byKey('tab-profile'));
    await settleAsync(tester);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(byKey('settings-section')).dx,
      greaterThan(tester.getTopLeft(byKey('profile-pets-section')).dx),
    );
    await tester.tap(byKey('profile-edit-owner'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    final Finder email = byKey('owner-form-email');
    final Finder phone = byKey('owner-form-phone');
    expect(tester.getTopLeft(email).dy, tester.getTopLeft(phone).dy);
    await resize(tester, 390);
    expect(tester.getTopLeft(email).dy, lessThan(tester.getTopLeft(phone).dy));
    expect(tester.takeException(), isNull);
  });
}
