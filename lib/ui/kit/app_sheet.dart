/// Bottom-sheet helpers shared by forms and action sheets.
library;

import 'package:flutter/material.dart';

import '../layout/adaptive_layout.dart';
import '../theme/app_theme.dart';

/// Opens the same form in a phone sheet or a centered wide-window dialog.
Future<T?> showAppSheet<T>(
  BuildContext context,
  WidgetBuilder builder, {
  bool isScrollControlled = true,
}) {
  if (AppLayout.usesDesktopLayout(context)) {
    return showDialog<T>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) => Dialog(
        backgroundColor: AppColors.surface,
        constraints: const BoxConstraints(maxWidth: 600),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
        clipBehavior: Clip.antiAlias,
        // Dialog already accounts for keyboard insets.
        child: SizedBox(width: 600, child: Builder(builder: builder)),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
    ),
    builder: builder,
  );
}

/// Standard sheet padding: 20 px sides, keyboard-aware bottom inset.
class AppSheetBody extends StatelessWidget {
  const AppSheetBody({
    super.key,
    required this.child,
    this.padding,
    this.scrollable = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom)
          .add(
            padding ??
                (AppLayout.usesDesktopLayout(context)
                    ? const EdgeInsets.all(AppSpacing.xl)
                    : const EdgeInsets.fromLTRB(20, 4, 20, 24)),
          ),
      child: scrollable ? SingleChildScrollView(child: child) : child,
    );
  }
}
