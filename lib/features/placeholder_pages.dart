import 'package:flutter/material.dart';

/// Placeholder pages for Step 1. Each will be replaced by a real screen
/// in later steps (Dashboard = Step 8+, Templates = Step 6, Settings = Step 3).
/// Submissions was replaced by the real page in Step 4
/// (`lib/features/submissions/submissions_page.dart`).

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dashboard'));
  }
}

// NOTE(Step 5): TemplatesPage was the Step 1 placeholder for the Courses /
// template tab. It has been replaced by the real `CoursesListPage`
// (lib/features/courses/courses_list_page.dart), which is now hosted directly
// in the shell's "Templates" rail destination — this class no longer exists.

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings'));
  }
}
