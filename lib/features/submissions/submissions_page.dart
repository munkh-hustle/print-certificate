import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add_submission_dialog.dart';
import 'submissions_providers.dart';

/// Step 4 — Submissions list fed by a Drift stream (fake/manual data only;
/// Google Sheets ingestion is Step 8+).
class SubmissionsPage extends ConsumerWidget {
  const SubmissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(submissionsListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const AddSubmissionDialog(),
        ),
        child: const Icon(Icons.add),
      ),
      body: submissionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Failed to load submissions:\n$err'),
        ),
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(
              child: Text('No submissions yet. Click + to add one.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: submissions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final s = submissions[index];
              return ListTile(
                title: Text('${s.surname} ${s.name}'),
                subtitle: Text(
                  '${s.certificateId ?? '—'} · ${s.civilNumber} · ${s.status}',
                ),
                // Trailing intentionally empty: print/preview buttons are
                // Steps 6–7.
              );
            },
          );
        },
      ),
    );
  }
}
