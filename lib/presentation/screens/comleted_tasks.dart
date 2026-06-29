import 'package:flutter/material.dart';
import 'package:tasky/data/models/task_model.dart';
import 'package:tasky/presentation/components/tasks_card.dart';

class CompletedTasksScreen extends StatefulWidget {
  final List<TaskModel> tasks;
  final ValueChanged<List<TaskModel>> onTasksChanged;
  final ValueChanged<TaskModel> onDeleteTask;
  final ValueChanged<TaskModel> onTaskCompleted;

  const CompletedTasksScreen({
    super.key,
    required this.tasks,
    required this.onTasksChanged,
    required this.onDeleteTask,
    required this.onTaskCompleted,
  });

  @override
  State<CompletedTasksScreen> createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<CompletedTasksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completed Tasks')),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: _buildCards(context),
      ),
    );
  }

  Widget _buildCards(BuildContext context) {
    final done = widget.tasks.where((t) => t.isDone).toList();

    if (done.isEmpty) {
      return Center(
        child: Text(
          'No Completed Tasks Yet',
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
        ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 65),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: done.length,
          itemBuilder: (_, i) => TaskCard(
            task: done[i],
            index: i,
            onChanged: () => widget.onTasksChanged(widget.tasks),
            onDelete: () => widget.onDeleteTask(done[i]),
            onMarkComplete: () => widget.onTaskCompleted(done[i]),
          ),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
        ),
      ],
    );
  }
}
