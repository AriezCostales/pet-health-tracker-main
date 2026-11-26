import 'package:flutter/material.dart';

import '../../../domain/dashboard.dart';
import '../../../domain/rules/vaccination_due.dart';
import '../../../ui/kit/app_card.dart';
import '../../../ui/theme/app_theme.dart';

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({
    super.key,
    required this.dashboard,
    required this.dueSoonDays,
  });

  final Dashboard dashboard;
  final int dueSoonDays;

  @override
  Widget build(BuildContext context) {
    final int overdue = dashboard.pets
        .where(
          (PetOverview pet) => pet.dueStatus == VaccinationDueStatus.overdue,
        )
        .length;
    final int dueSoon = dashboard.pets
        .where(
          (PetOverview pet) => pet.dueStatus == VaccinationDueStatus.dueSoon,
        )
        .length;
    final List<Widget> tiles = <Widget>[
      _Metric(
        label: 'Pets',
        value: dashboard.pets.length,
        detail: 'In the household',
        icon: Icons.pets_outlined,
      ),
      _Metric(
        label: 'Pets overdue',
        value: overdue,
        detail: 'Vaccines past due',
        icon: Icons.error_outline,
        foreground: AppColors.overdue,
        background: AppColors.overdueSurface,
      ),
      _Metric(
        label: 'Pets due soon',
        value: dueSoon,
        detail: 'Within $dueSoonDays days',
        icon: Icons.schedule_outlined,
        foreground: AppColors.dueSoon,
        background: AppColors.dueSoonSurface,
      ),
      _Metric(
        label: 'Visits this week',
        value: dashboard.visitsThisWeek,
        detail: 'Monday to Sunday',
        icon: Icons.event_available_outlined,
        foreground: AppColors.accent,
        background: AppColors.accentSurface,
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = AppSpacing.md;
        final double scaledText = MediaQuery.textScalerOf(context).scale(1);
        final double minimumTile = 172 * scaledText.clamp(1.0, 1.45);
        final int columns = switch (constraints.maxWidth) {
          final double width when width >= minimumTile * 4 + gap * 3 => 4,
          final double width when width >= minimumTile * 2 + gap => 2,
          _ => 1,
        };

        return Column(
          children: <Widget>[
            for (int start = 0; start < tiles.length; start += columns) ...[
              if (start > 0) const SizedBox(height: gap),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (int column = 0; column < columns; column++) ...[
                    if (column > 0) const SizedBox(width: gap),
                    Expanded(child: tiles[start + column]),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    this.foreground = AppColors.ink,
    this.background = AppColors.surface,
  });

  final String label;
  final int value;
  final String detail;
  final IconData icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final Color outline = background == AppColors.surface
        ? AppColors.hairline
        : Color.alphaBlend(foreground.withValues(alpha: 0.16), background);

    return Semantics(
      container: true,
      label: '$label: $value. $detail.',
      excludeSemantics: true,
      child: AppCard(
        borderColor: outline,
        color: background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Text(
                    '$value',
                    style: AppTextStyles.metric.copyWith(color: foreground),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(icon, size: 20, color: foreground),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium!
                  .copyWith(color: foreground),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(detail, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
