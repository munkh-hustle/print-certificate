import 'package:flutter/material.dart';

/// Named routes used with the plain `Navigator` (no external deps).
///
/// The root shell (`HomeShell` in `lib/main.dart`) hosts a
/// `NavigationRail` whose four destinations are listed here. Detail
/// screens from later steps (e.g. a submission editor) can be pushed
/// via [AppRoutes.submissionDetail] using `Navigator.pushNamed`.
class AppRoutes {
  const AppRoutes._();

  static const String dashboard = '/dashboard';
  static const String submissions = '/submissions';
  static const String templates = '/templates';
  static const String settings = '/settings';

  /// Later steps: push a detail page for one submission, e.g.
  /// `Navigator.of(context).pushNamed(AppRoutes.submissionDetail, arguments: id)`
  static const String submissionDetail = '/submission';

  static List<String> get railDestinations => const [
        dashboard,
        submissions,
        templates,
        settings,
      ];
}

/// Description of one tab shown in the left-hand `NavigationRail`.
class RailDestination {
  const RailDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.bodyBuilder,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder bodyBuilder;
}
