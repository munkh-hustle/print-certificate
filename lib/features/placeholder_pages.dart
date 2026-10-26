import 'package:flutter/material.dart';

/// Placeholder pages for Step 1. Each will be replaced by a real screen
/// in later steps (Dashboard = Step 8+, Templates = Step 6, Settings = Step 3).
///
/// Submissions was replaced by the real page in Step 4 — see
/// `lib/features/submissions/submissions_page.dart` (the old placeholder
/// `SubmissionsPage` here was removed to avoid a name clash with main.dart's
/// imports).

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dashboard'));
  }
}

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Templates'));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings'));
  }
}
