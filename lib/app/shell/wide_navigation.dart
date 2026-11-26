import 'package:flutter/material.dart';

import '../../ui/theme/app_theme.dart';
import 'shell_destinations.dart';

class WideNavigation extends StatelessWidget {
  const WideNavigation({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  static const double compactWidth = 72;
  static const double expandedWidth = 232;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < compactWidth) {
          return const SizedBox.shrink();
        }
        // Match the actual animated width to keep labels from overflowing
        // while the sidebar is moving.
        final bool extended = constraints.maxWidth >= expandedWidth - 24;
        return Material(
          color: AppColors.paper,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.hairline)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - AppSpacing.md * 2).clamp(
                    0,
                    double.infinity,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                          child: Row(
                            mainAxisAlignment: extended
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.accentSurface,
                                  borderRadius: AppRadii.controlRadius,
                                ),
                                child: const Icon(
                                  Icons.pets_outlined,
                                  color: AppColors.accent,
                                  semanticLabel: 'Pet Health Tracker',
                                ),
                              ),
                              if (extended) ...<Widget>[
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: ExcludeSemantics(
                                    child: Text(
                                      'Pet Health Tracker',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        for (
                          int index = 0;
                          index < shellDestinations.length - 1;
                          index++
                        )
                          _destination(index, extended),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: AppSpacing.lg),
                        const Divider(),
                        const SizedBox(height: AppSpacing.sm),
                        _destination(shellDestinations.length - 1, extended),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _destination(int index, bool extended) {
    final ShellDestination destination = shellDestinations[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: _Destination(
        key: destination.key,
        icon: index == 0 ? Icons.dashboard_outlined : destination.icon,
        label: index == 0 ? 'Dashboard' : destination.label,
        extended: extended,
        selected: index == currentIndex,
        shortcut: 'Alt+${index + 1}',
        onTap: () => onSelect(index),
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination({
    super.key,
    required this.icon,
    required this.label,
    required this.extended,
    required this.selected,
    required this.shortcut,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool extended;
  final bool selected;
  final String shortcut;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected ? AppColors.accent : AppColors.secondary;
    final BorderRadius radius = AppRadii.controlRadius;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Tooltip(
        message: '$label ($shortcut)',
        excludeFromSemantics: true,
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? AppColors.accentSurface : Colors.transparent,
            borderRadius: radius,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            focusColor: AppColors.focus.withValues(alpha: 0.19),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                mainAxisAlignment: extended
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: <Widget>[
                  if (extended) const SizedBox(width: AppSpacing.md),
                  Icon(icon, color: foreground, size: 22),
                  if (extended) ...<Widget>[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ExcludeSemantics(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body.copyWith(
                            color: foreground,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WorkspaceBar extends StatelessWidget {
  const WorkspaceBar({
    super.key,
    required this.title,
    required this.onQuickActions,
    this.onToggleNavigation,
    this.onOpenDrawer,
    this.onOpenDashboard,
    this.extended = false,
  });

  final String title;
  final VoidCallback onQuickActions;
  final VoidCallback? onToggleNavigation;
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onOpenDashboard;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(bottom: BorderSide(color: AppColors.hairline)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              if (onOpenDrawer != null) ...<Widget>[
                IconButton(
                  key: const ValueKey<String>('open-desktop-navigation'),
                  tooltip: 'Open navigation',
                  onPressed: onOpenDrawer,
                  icon: const Icon(Icons.menu),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              if (onToggleNavigation != null) ...<Widget>[
                IconButton(
                  key: const ValueKey<String>('toggle-sidebar'),
                  tooltip: extended ? 'Collapse sidebar' : 'Expand sidebar',
                  onPressed: onToggleNavigation,
                  icon: const Icon(Icons.view_sidebar_outlined),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Semantics(
                  container: true,
                  headingLevel: 1,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (onOpenDashboard != null)
                IconButton(
                  key: const ValueKey<String>('open-dashboard'),
                  tooltip: 'Dashboard',
                  onPressed: onOpenDashboard,
                  icon: const Icon(Icons.dashboard_outlined),
                ),
              if (onOpenDrawer != null)
                IconButton.filled(
                  key: const ValueKey<String>('centre-action'),
                  tooltip: 'Quick actions',
                  onPressed: onQuickActions,
                  icon: const Icon(Icons.add, size: 20),
                )
              else
                Tooltip(
                  message: 'Quick actions (Ctrl+N)',
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.controlRadius,
                      ),
                    ),
                    key: const ValueKey<String>('centre-action'),
                    onPressed: onQuickActions,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Quick actions'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
