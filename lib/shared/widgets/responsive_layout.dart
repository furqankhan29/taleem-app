import 'package:flutter/material.dart';
import 'package:taleem/core/utils/extensions.dart';

class ResponsiveLayout extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (context.isDesktop) {
          return desktop(context);
        } else if (context.isTablet) {
          return (tablet ?? mobile)(context);
        } else {
          return mobile(context);
        }
      },
    );
  }
}
