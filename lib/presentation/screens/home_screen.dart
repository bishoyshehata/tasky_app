import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:tasky/core/theme/app_sizes.dart';
import 'package:tasky/core/theme/app_theme_notifier.dart';
import 'package:tasky/data/models/task_model.dart';
import 'package:tasky/data/models/user_model.dart';
import 'package:tasky/presentation/components/achieved_tasks.dart';
import 'package:tasky/presentation/components/tasks_card.dart';
import 'package:tasky/presentation/screens/add_task._screen.dart';

class HomeScreen extends StatefulWidget {
  final List<TaskModel> tasks;
  final ValueChanged<List<TaskModel>> onTasksChanged;
  final ValueChanged<TaskModel> onTaskAdded;
  final ValueChanged<TaskModel> onEditTask;
  final ValueChanged<TaskModel> onDeleteTask;
  final ValueChanged<TaskModel> onTaskCompleted;
  final UserModel? userModel;

  const HomeScreen({
    super.key,
    required this.tasks,
    required this.onTasksChanged,
    required this.onTaskAdded,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onTaskCompleted,
    this.userModel,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppW.w12),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: AppR.r25,
                      backgroundImage:
                          (widget.userModel?.profileImageBytes != null)
                          ? MemoryImage(widget.userModel!.profileImageBytes!)
                          : const AssetImage('assets/images/file.jpg')
                                as ImageProvider,
                    ),
                    SizedBox(width: AppW.w4),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            '${_greeting()}, ${widget.userModel?.name ?? ''} ',
                            style: TextStyle(fontSize: AppSp.sp18),
                            minFontSize: 14,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.userModel?.motivationQuote ??
                                'One task at a time. One step closer.',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: AppSp.sp16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      onPressed: AppThemeNotifier.instance.toggle,
                      icon: ValueListenableBuilder<ThemeMode>(
                        valueListenable: AppThemeNotifier.instance,
                        builder: (_, mode, __) => Icon(
                          mode == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppH.h20),
                Text(
                  'Small steps lead to',
                  style: TextStyle(fontSize: AppSp.sp24),
                ),
                Row(
                  children: [
                    Text(
                      'big achievements! ',
                      style: TextStyle(fontSize: AppSp.sp20),
                    ),
                    SvgPicture.asset(
                      'assets/images/hand.svg',
                      width: AppW.w40,
                      height: AppH.h40,
                    ),
                  ],
                ),

                SizedBox(height: AppH.h100),
                if (widget.tasks.isEmpty)
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: AppW.w250,
                          height: AppH.h250,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(bottom: AppH.h40),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Lottie.asset(
                            'assets/lottie/to_do.json',

                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          'No Tasks Yet',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: AppSp.sp18,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      AchievedTasks(
                        allTasks: widget.tasks.length,
                        achievedTasks: widget.tasks
                            .where((t) => t.isDone)
                            .length,
                      ),
                      SizedBox(height: AppH.h10),
                      _buildHighPriority(),
                      SizedBox(height: AppH.h10),
                      widget.tasks.where((t) => !t.isHighPriority).isEmpty
                          ? SizedBox.shrink()
                          : _buildTaskCards(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────
      floatingActionButton: SizedBox(
        height: AppH.h40,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push<TaskModel>(
              context,
              MaterialPageRoute(builder: (_) => const AddTaskScreen()),
            );
            if (result != null) {
              widget.onTaskAdded(result);
              _showReminderSnackbar(result, 'added');
            }
          },
          label: Text(
            'Add New Task',
            style: TextStyle(fontSize: AppSp.sp14, fontWeight: FontWeight.w500),
          ),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTaskCards() {
    final reversed = widget.tasks
        .where((t) => !t.isHighPriority)
        .toList()
        .reversed
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppW.w16),
          child: Text(
            'My Tasks',
            style: TextStyle(fontSize: AppSp.sp20, fontWeight: FontWeight.w400),
          ),
        ),
        SizedBox(height: AppH.h12),
        ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 65),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reversed.length,
          itemBuilder: (_, i) => TaskCard(
            task: reversed[i],
            index: i,
            onChanged: () => widget.onTasksChanged(widget.tasks),
            onEdit: () => _handleEdit(reversed[i]),
            onDelete: () => widget.onDeleteTask(reversed[i]),
            onMarkComplete: () => widget.onTaskCompleted(reversed[i]),
          ),
          separatorBuilder: (_, __) => SizedBox(height: AppH.h12),
        ),
      ],
    );
  }

  Widget _buildHighPriority() {
    final hp = widget.tasks
        .where((t) => t.isHighPriority)
        .toList()
        .reversed
        .toList();

    if (hp.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppR.r20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16.0),
            child: Text(
              'High Priority Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: AppH.h6),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hp.length,
            itemBuilder: (_, i) => TaskCard(
              task: hp[i],
              index: i,
              onChanged: () => widget.onTasksChanged(widget.tasks),
              onEdit: () => _handleEdit(hp[i]),
              onDelete: () => widget.onDeleteTask(hp[i]),
              onMarkComplete: () => widget.onTaskCompleted(hp[i]),
            ),
            separatorBuilder: (_, __) => SizedBox(height: AppH.h12),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Good Morning';
    if (h >= 12 && h < 17) return 'Good Afternoon';
    return 'Good Evening';
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
