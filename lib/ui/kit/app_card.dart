/// White rounded surface for grouped content.
library;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Paper card with a hairline outline, tappable when [onTap]
/// is provided.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color = AppColors.surface,
    this.borderColor = AppColors.hairline,
    this.radius = AppRadii.card,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final BorderRadius shape = BorderRadius.circular(radius);
    final Widget card = Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: shape,
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: shape),
        child: Padding(padding: padding, child: child),
      ),
    );
    return onTap == null
        ? card
        : Semantics(container: true, button: true, child: card);
  }
}
