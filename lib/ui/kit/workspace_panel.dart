import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';

/// A titled surface for grouped workspace data and its related action.
class WorkspacePanel extends StatelessWidget {
  const WorkspacePanel({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.md,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Semantics(
                      container: true,
                      headingLevel: 2,
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  ?action,
                ],
              ),
            ),
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }
}
