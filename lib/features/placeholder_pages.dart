import 'package:flutter/material.dart';

/// Placeholder pages for Step 1. Each will be replaced by a real screen
/// in later steps (Dashboard = Step 8+, Submissions = Step 4, Templates =
/// Step 6, Settings = Step 3).

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dashboard'));
  }
}

class SubmissionsPage extends StatelessWidget {
  const SubmissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Submissions'));
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
