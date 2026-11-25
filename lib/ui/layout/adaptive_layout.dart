import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Window breakpoints in logical pixels. Content columns also check their
/// local constraints because the navigation takes up some of the window.
abstract final class AppLayout {
  static const double tablet = 640;
  static const double desktop = 1024;
  static const double expandedSidebar = 1280;
  static const double largeDesktop = 1536;
  static const double contentMaxWidth = 1380;
  static const double columnMinWidth = 320;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static double pageGutter(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= largeDesktop) {
      return AppSpacing.xxl;
    }
    return width >= expandedSidebar ? AppSpacing.xl : AppSpacing.lg;
  }
}

/// Centers a page within the available area while preserving the child's
/// vertical constraints and scroll behavior.
class PageContent extends StatelessWidget {
  const PageContent({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.contentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppLayout.isWide(context) ? maxWidth : double.infinity,
        ),
        child: SizedBox.expand(child: child),
      ),
    );
  }
}

/// Reflows two independent sections based on usable content width.
class AdaptiveColumns extends StatelessWidget {
  const AdaptiveColumns({
    super.key,
    required this.first,
    required this.second,
    this.minColumnWidth = AppLayout.columnMinWidth,
    this.gap = AppSpacing.lg,
  });

  final Widget first;
  final Widget second;
  final double minColumnWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool sideBySide =
            constraints.maxWidth >= minColumnWidth * 2 + gap;
        return Flex(
          direction: sideBySide ? Axis.horizontal : Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: sideBySide
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(flex: sideBySide ? 1 : 0, child: first),
            SizedBox(width: sideBySide ? gap : 0, height: sideBySide ? 0 : gap),
            Expanded(flex: sideBySide ? 1 : 0, child: second),
          ],
        );
      },
    );
  }
}
