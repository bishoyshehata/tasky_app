import 'package:flutter/material.dart';
import 'package:tasky/data/models/task_model.dart';
import 'package:tasky/presentation/components/tasks_card.dart';

class ArchivedTasksScreen extends StatefulWidget {
  final List<TaskModel> tasks;
  final ValueChanged<List<TaskModel>> onTasksChanged;

  const ArchivedTasksScreen({
    super.key,
    required this.tasks,
    required this.onTasksChanged,
  });

  @override
  State<ArchivedTasksScreen> createState() => _ArchivedTasksScreenState();
}

class _ArchivedTasksScreenState extends State<ArchivedTasksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Tasks'),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: _buildCards(context),
      ),
    );
  }

  Widget _buildCards(BuildContext context) {
    final archived = widget.tasks.where((t) => t.isArchived).toList();

    if (archived.isEmpty) {
      return Center(
        child: Text(
          'No Archived Tasks',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 18,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // A banner to inform the user about the auto-delete policy
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Archived tasks are read-only and will be permanently deleted after 7 days.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 65),
            itemCount: archived.length,
            itemBuilder: (_, i) => TaskCard(
              task: archived[i],
              index: i,
              isReadOnly: true,
              // Since it's read only, these won't be called, but we provide empty or valid callbacks
              onChanged: () {},
              onEdit: () {},
              onDelete: () {
                // If we want to allow manual deletion from archive, we can implement it here.
                // But user didn't ask for it, so we can just leave it since the more-menu is hidden.
              },
            ),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          ),
        ),
      ],
    );
  }
}
