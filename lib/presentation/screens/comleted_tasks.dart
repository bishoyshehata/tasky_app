import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tasky/data/models/task_model.dart';
import 'package:tasky/presentation/components/tasks_card.dart';
import 'package:tasky/presentation/screens/add_task._screen.dart';
import 'package:tasky/core/theme/app_sizes.dart';

class CompletedTasksScreen extends StatefulWidget {
  final List<TaskModel> tasks;
  final ValueChanged<List<TaskModel>> onTasksChanged;
  final ValueChanged<TaskModel> onEditTask;
  final ValueChanged<TaskModel> onDeleteTask;
  final ValueChanged<TaskModel> onTaskCompleted;
  final ValueChanged<TaskModel> onArchiveTask;

  const CompletedTasksScreen({
    super.key,
    required this.tasks,
    required this.onTasksChanged,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onTaskCompleted,
    required this.onArchiveTask,
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
        margin: EdgeInsets.symmetric(horizontal: AppW.w12),
        child: _buildCards(context),
      ),
    );
  }

  Widget _buildCards(BuildContext context) {
    final done = widget.tasks.where((t) => t.isDone && !t.isArchived).toList();

    if (done.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: AppH.h250,
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: AppH.h40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Lottie.asset(
              'assets/lottie/completed.json',

              fit: BoxFit.cover,
            ),
          ),
          Text(
            'No Completed Tasks Yet',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: AppSp.sp18,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: AppH.h12),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.only(bottom: AppH.h65),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: done.length,
          itemBuilder: (_, i) => TaskCard(
            task: done[i],
            index: i,
            onChanged: () => widget.onTasksChanged(widget.tasks),
            onEdit: () => _handleEdit(done[i]),
            onDelete: () => widget.onDeleteTask(done[i]),
            onMarkComplete: () => widget.onTaskCompleted(done[i]),
            onArchive: () => widget.onArchiveTask(done[i]),
          ),
          separatorBuilder: (_, __) => SizedBox(height: AppH.h12),
        ),
        Container(
          width: AppW.w200,
          height: AppH.h200,
          alignment: Alignment.center,
          margin: EdgeInsets.only(bottom: AppH.h40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Lottie.asset(
            'assets/lottie/completed.json',

            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Future<void> _handleEdit(TaskModel task) async {
    final updated = await Navigator.push<TaskModel>(
      context,
      MaterialPageRoute(builder: (_) => AddTaskScreen(taskToEdit: task)),
    );
    if (updated != null) {
      widget.onEditTask(updated);
      _showReminderSnackbar(updated, 'updated');
    }
  }

  void _showReminderSnackbar(TaskModel task, String action) {
    if (!task.reminderEnabled || task.reminderDate == null) return;

    final diff = task.reminderDate!.difference(DateTime.now());
    if (diff.isNegative) return;

    String timeStr = '';
    if (diff.inDays > 0) {
      timeStr = '${diff.inDays} day(s)';
    } else if (diff.inHours > 0) {
      timeStr = '${diff.inHours} hour(s) and ${diff.inMinutes % 60} minute(s)';
    } else {
      timeStr = '${diff.inMinutes} minute(s)';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task $action. You will be reminded in $timeStr.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
