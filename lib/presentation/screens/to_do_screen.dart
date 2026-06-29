import 'package:flutter/material.dart';
import 'package:tasky/data/models/task_model.dart';
import 'package:tasky/presentation/components/tasks_card.dart';

class TodoScreen extends StatefulWidget {
  final List<TaskModel> tasks;
  final ValueChanged<List<TaskModel>> onTasksChanged;
  final ValueChanged<TaskModel> onDeleteTask;
  final ValueChanged<TaskModel> onTaskCompleted;

  const TodoScreen({
    super.key,
    required this.tasks,
    required this.onTasksChanged,
    required this.onDeleteTask,
    required this.onTaskCompleted,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To Do Tasks')),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: _buildCards(context),
      ),
    );
  }

  Widget _buildCards(BuildContext context) {
    final todo = widget.tasks.where((t) => !t.isDone).toList();

    if (todo.isEmpty) {
      return Center(
        child: Text(
          'No Tasks Yet',
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
          itemCount: todo.length,
          itemBuilder: (_, i) => TaskCard(
            task: todo[i],
            index: i,
            onChanged: () => widget.onTasksChanged(widget.tasks),
            onDelete: () => widget.onDeleteTask(todo[i]),
            onMarkComplete: () => widget.onTaskCompleted(todo[i]),
          ),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
        ),
      ],
    );
  }
}
