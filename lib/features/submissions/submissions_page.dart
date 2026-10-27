import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../providers/submissions_provider.dart';
import 'add_submission_dialog.dart';

/// Step 4 — Submissions list backed by a Drift stream (fake/manual data only;
/// Google Sheets ingestion comes in Step 8).
class SubmissionsPage extends ConsumerWidget {
  const SubmissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(submissionsListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: submissionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text('Could not load submissions:\n$e',
              textAlign: TextAlign.center),
        ),
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(
              child: Text('No submissions yet. Click + to add one.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: submissions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) => _SubmissionTile(
                submission: submissions[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddSubmissionDialog(context),
        tooltip: 'Add submission',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SubmissionTile extends StatelessWidget {
  const _SubmissionTile({required this.submission});

  final Submission submission;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${submission.surname} ${submission.name}'),
      subtitle: Text(
        '${submission.certificateId ?? '—'} · '
        '${submission.civilNumber} · '
        '${submission.status}',
      ),
      // Trailing intentionally empty — print/preview buttons are Steps 6–7.
    );
  }
}
