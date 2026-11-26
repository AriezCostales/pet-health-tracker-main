/// The navigation shell: four destinations, a raised centre action, and tab
/// state retained by `StatefulShellRoute.indexedStack`.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../ui/layout/adaptive_layout.dart';
import '../../ui/theme/app_theme.dart';
import 'centre_action_sheet.dart';
import 'shell_destinations.dart';
import 'wide_navigation.dart';

export 'shell_destinations.dart';

/// Height of the bar itself (the raised button adds 26 px above it).
/// How far the bar's content (tabs and the centre action) sits below the top of
/// the paper, to close the gap above the screen's bottom edge.
const double kShellBarContentTop = 6;

/// Height of the paper bar below the content. Independent of the centre
/// action: the action is centred inside it, so growing the bar gives the tab
/// items and the action the same clearance under the hairline.
const double kShellBarHeight = 76;

/// The raised centre action protrudes this far above the bar, so scrollable
/// screens leave at least this much room (plus air) below their last row.
const double kShellContentBottomPadding = 48;

/// Wraps every branch: keeps all four screens alive in an [IndexedStack] and
/// paints the bar plus the raised centre action.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  /// Fade-through between destinations: the body dips out, the branch swaps
  /// while invisible, then it fades back in. Branch state is retained by the
  /// shell's IndexedStack. A second tap supersedes the first instead of being
  /// ignored, so the bar never goes dead.
  static const Duration _fadeOut = Duration(milliseconds: 80);
  static const Duration _fadeIn = Duration(milliseconds: 200);

  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: _fadeIn,
    value: 1,
  );

  int _generation = 0;
  bool? _sidebarExpanded;

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  Future<void> _select(int index) async {
    final StatefulNavigationShell shell = widget.navigationShell;
    if (index == shell.currentIndex) {
      // Tapping the tab that is already showing must also cancel a switch that
      // is still fading out — otherwise the earlier tap wins and the app lands
      // on a tab the user did not choose last.
      _generation += 1;
      _fade.value = 1;
      // Tapping the current tab returns it to its initial route.
      shell.goBranch(index, initialLocation: true);
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _generation += 1;
      _fade.value = 1;
      shell.goBranch(index);
      return;
    }
    final int generation = ++_generation;
    _fade.duration = _fadeOut;
    try {
      await _fade.reverse().orCancel;
    } on TickerCanceled {
      return;
    }
    if (!mounted || generation != _generation) {
      return;
    }
    shell.goBranch(index);
    _fade.duration = _fadeIn;
    _fade.forward();
  }

  @override
  Widget build(BuildContext context) {
    final bool desktop = AppLayout.usesDesktopLayout(context);
    final double width = MediaQuery.sizeOf(context).width;
    final bool showSidebar = desktop && width >= AppLayout.sidebarMinWidth;
    final bool useDrawer = desktop && !showSidebar;
    final bool canToggleSidebar =
        desktop && width >= AppLayout.sidebarToggleMinWidth;
    final bool extended =
        canToggleSidebar &&
        (_sidebarExpanded ?? width >= AppLayout.expandedSidebar);
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final int selected = widget.navigationShell.currentIndex;

    void quickActions() => showCentreActionSheet(context);

    return PopScope(
      canPop: selected == AppShellSelection.home,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _select(AppShellSelection.home);
        }
      },
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          if (desktop) ...<ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.digit1, alt: true): () =>
                _select(0),
            const SingleActivator(LogicalKeyboardKey.digit2, alt: true): () =>
                _select(1),
            const SingleActivator(LogicalKeyboardKey.digit3, alt: true): () =>
                _select(2),
            const SingleActivator(LogicalKeyboardKey.digit4, alt: true): () =>
                _select(3),
            const SingleActivator(LogicalKeyboardKey.keyN, control: true):
                quickActions,
            const SingleActivator(LogicalKeyboardKey.keyN, meta: true):
                quickActions,
          },
        },
        child: FocusTraversalGroup(
          child: Focus(
            autofocus: desktop,
            child: Scaffold(
              drawer: useDrawer
                  ? Drawer(
                      width: WideNavigation.expandedWidth,
                      backgroundColor: AppColors.paper,
                      child: SafeArea(
                        child: Builder(
                          builder: (BuildContext drawerContext) =>
                              WideNavigation(
                                currentIndex: selected,
                                onSelect: (int index) {
                                  Scaffold.of(drawerContext).closeDrawer();
                                  _select(index);
                                },
                              ),
                        ),
                      ),
                    )
                  : null,
              body: SafeArea(
                top: desktop,
                bottom: desktop,
                left: desktop,
                right: desktop,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AnimatedContainer(
                      duration: showSidebar && !reduceMotion
                          ? AppMotion.panel
                          : Duration.zero,
                      curve: Curves.easeOutCubic,
                      width: showSidebar
                          ? (extended
                                ? WideNavigation.expandedWidth
                                : WideNavigation.compactWidth)
                          : 0,
                      child: showSidebar
                          ? WideNavigation(
                              currentIndex: selected,
                              onSelect: _select,
                            )
                          : null,
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          if (desktop)
                            Builder(
                              builder: (BuildContext barContext) =>
                                  WorkspaceBar(
                                    title: selected == AppShellSelection.home
                                        ? 'Dashboard'
                                        : shellDestinations[selected].label,
                                    extended: extended,
                                    onQuickActions: quickActions,
                                    onOpenDashboard: useDrawer
                                        ? () => _select(AppShellSelection.home)
                                        : null,
                                    onOpenDrawer: useDrawer
                                        ? Scaffold.of(barContext).openDrawer
                                        : null,
                                    onToggleNavigation: canToggleSidebar
                                        ? () => setState(
                                            () => _sidebarExpanded = !extended,
                                          )
                                        : null,
                                  ),
                            )
                          else
                            const SizedBox.shrink(),
                          Expanded(
                            child: AppShellSelection(
                              select: _select,
                              child: FadeTransition(
                                opacity: _fade,
                                child: widget.navigationShell,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: desktop
                  ? null
                  : AppShellBar(
                      currentIndex: selected,
                      onSelect: _select,
                      onCentreAction: quickActions,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets a screen ask the shell to switch destination — so a tap inside a page
/// gets the same fade as a tap on the bar, instead of an instant `context.go`.
class AppShellSelection extends InheritedWidget {
  const AppShellSelection({
    super.key,
    required this.select,
    required super.child,
  });

  /// Branch indexes in the shell's destination order.
  static const int home = 0;
  static const int journal = 1;
  static const int appointments = 2;
  static const int profile = 3;

  final ValueChanged<int> select;

  static AppShellSelection? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShellSelection>();

  @override
  bool updateShouldNotify(AppShellSelection oldWidget) =>
      select != oldWidget.select;
}

/// Paper bar with a hairline top edge, four tab items and the accent centre
/// button lifted above the bar.
class AppShellBar extends StatelessWidget {
  const AppShellBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.onCentreAction,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCentreAction;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final double barHeight = kShellBarHeight + bottomInset;

    return SizedBox(
      height: barHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.hairline)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: kShellBarContentTop,
            height: kShellBarHeight,
            child: Row(
              children: <Widget>[
                _ShellDestinationButton(
                  destination: shellDestinations[0],
                  selected: currentIndex == 0,
                  onTap: () => onSelect(0),
                ),
                _ShellDestinationButton(
                  destination: shellDestinations[1],
                  selected: currentIndex == 1,
                  onTap: () => onSelect(1),
                ),
                const SizedBox(width: 76),
                _ShellDestinationButton(
                  destination: shellDestinations[2],
                  selected: currentIndex == 2,
                  onTap: () => onSelect(2),
                ),
                _ShellDestinationButton(
                  destination: shellDestinations[3],
                  selected: currentIndex == 3,
                  onTap: () => onSelect(3),
                ),
              ],
            ),
          ),
          // A touch above the bar's centre line, so its top edge lands on the
          // tab icons' optical line rather than below it.
          Positioned(
            top:
                (kShellBarHeight - CentreActionButton.height) / 2 -
                6 +
                kShellBarContentTop,
            left: 0,
            right: 0,
            child: Center(
              child: CentreActionButton(
                key: const ValueKey<String>('centre-action'),
                onPressed: onCentreAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShellDestinationButton extends StatelessWidget {
  const _ShellDestinationButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? AppColors.accent : AppColors.secondary;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: destination.label,
        excludeSemantics: true,
        child: InkWell(
          key: destination.key,
          onTap: onTap,
          // Same rule as rows and chips: a tappable surface paints a rounded
          // highlight, never a rectangle behind the label.
          borderRadius: BorderRadius.circular(AppRadii.chip),
          child: SizedBox(
            height: kShellBarHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  size: 22,
                  color: color,
                ),
                const SizedBox(height: 2),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The raised accent circle in the middle of the bar.
class CentreActionButton extends StatelessWidget {
  const CentreActionButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  /// A small rounded rectangle, not a stadium: the corner radius stays well
  /// under half the height so it reads as a square with soft corners.
  static const double width = 60;
  static const double height = 44;
  static const double _ring = 4;
  static const BorderRadius _outer = BorderRadius.all(Radius.circular(16));
  static const BorderRadius _inner = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add',
      child: Container(
        padding: const EdgeInsets.all(_ring),
        decoration: const BoxDecoration(
          color: AppColors.paper,
          borderRadius: _outer,
        ),
        child: Material(
          color: AppColors.accent,
          borderRadius: _inner,
          elevation: 4,
          shadowColor: const Color(0x330E6B5F),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            borderRadius: _inner,
            child: const SizedBox(
              width: width - _ring * 2,
              height: height - _ring * 2,
              child: Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
