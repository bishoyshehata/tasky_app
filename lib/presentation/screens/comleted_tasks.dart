import 'package:flutter/material.dart';
import 'package:tasky/data/models/task_model.dart';
import 'package:tasky/presentation/components/tasks_card.dart';

class CompletedTasksScreen extends StatefulWidget {
  final List<TaskModel> tasks;
  final ValueChanged<List<TaskModel>> onTasksChanged;

  const CompletedTasksScreen({
    super.key,
    required this.tasks,
    required this.onTasksChanged,
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
        margin: const EdgeInsets.only(left: 12.0, right: 12.0),
        child: buildTaskCards(context),
      ),
    );
  }

  Widget buildTaskCards(BuildContext context) {
    final completedTasks = widget.tasks.where((task) => task.isDone).toList();

    if (completedTasks.isEmpty) {
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
          itemCount: completedTasks.length,
          itemBuilder: (context, index) {
            return TaskCard(
              task: completedTasks[index],
              index: index,
              onChanged: () {
                widget.onTasksChanged(widget.tasks);
              },
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
        ),
      ],
    );
  }
}
