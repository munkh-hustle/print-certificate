import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'features/courses/courses_list_page.dart';
import 'features/placeholder_pages.dart';
import 'features/settings/settings_screen.dart';
import 'features/submissions/submissions_page.dart';

void main() {
  runApp(const ProviderScope(child: DisboxApp()));
}

class DisboxApp extends StatelessWidget {
  const DisboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disbox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomeShell(),
      routes: {
        // Deep-linkable named routes; the shell owns the rail state.
        AppRoutes.dashboard: (_) => const HomeShell(initialTab: 0),
        AppRoutes.submissions: (_) => const HomeShell(initialTab: 1),
        AppRoutes.templates: (_) => const HomeShell(initialTab: 2),
        AppRoutes.settings: (_) => const HomeShell(initialTab: 3),
      },
    );
  }
}

/// Root shell: left-hand [NavigationRail] + the body of the active tab.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _selectedIndex = widget.initialTab;

  static final List<RailDestination> _destinations = [
    RailDestination(
      label: 'Dashboard',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard,
      bodyBuilder: (_) => DashboardPage(),
    ),
    RailDestination(
      label: 'Submissions',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
      bodyBuilder: (_) => const SubmissionsPage(),
    ),
    RailDestination(
      label: 'Templates',
      icon: Icons.description_outlined,
      selectedIcon: Icons.description,
      // Step 5: real Courses management page (was the TemplatesPage placeholder).
      bodyBuilder: (_) => const CoursesListPage(),
    ),
    RailDestination(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      bodyBuilder: (_) => const SettingsScreen(),
    ),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final destination = _destinations[_selectedIndex];

    return Scaffold(
      appBar: AppBar(title: Text(destination.label)),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: Builder(builder: destination.bodyBuilder)),
        ],
      ),
    );
  }
}
