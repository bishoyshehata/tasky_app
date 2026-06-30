import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:engez/core/theme/app_sizes.dart';
import 'package:engez/core/theme/app_theme_notifier.dart';
import 'package:engez/data/models/task_model.dart';
import 'package:engez/data/models/user_model.dart';
import 'package:engez/l10n/app_localizations.dart';
import 'package:engez/presentation/components/achieved_tasks.dart';
import 'package:engez/presentation/components/tasks_card.dart';
import 'package:engez/presentation/screens/add_task._screen.dart';

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
    final l = AppLocalizations.of(context);

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
                            '${_greeting(l)}, ${widget.userModel?.name ?? ''} ',
                            style: TextStyle(fontSize: AppSp.sp18),
                            minFontSize: 14,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.userModel?.motivationQuote ??
                                l.motivationDefault,
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
                  l.homeTagline1,
                  style: TextStyle(fontSize: AppSp.sp24),
                ),
                Row(
                  children: [
                    Text(
                      l.homeTagline2,
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
                          l.noTasksYet,
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
                      _buildHighPriority(l),
                      SizedBox(height: AppH.h10),
                      widget.tasks.where((t) => !t.isHighPriority).isEmpty
                          ? const SizedBox.shrink()
                          : _buildTaskCards(l),
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
              _showReminderSnackbar(result, l.taskAdded, l);
            }
          },
          label: Text(
            l.addNewTask,
            style: TextStyle(fontSize: AppSp.sp14, fontWeight: FontWeight.w500),
          ),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTaskCards(AppLocalizations l) {
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
            l.myTasks,
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
            onEdit: () => _handleEdit(reversed[i], l),
            onDelete: () => widget.onDeleteTask(reversed[i]),
            onMarkComplete: () => widget.onTaskCompleted(reversed[i]),
          ),
          separatorBuilder: (_, __) => SizedBox(height: AppH.h12),
        ),
      ],
    );
  }

  Widget _buildHighPriority(AppLocalizations l) {
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
            padding: EdgeInsets.only(top: AppH.h8, left: AppW.w16),
            child: Text(
              l.highPriorityTasks,
              style: TextStyle(
                fontSize: AppSp.sp20,
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
              onEdit: () => _handleEdit(hp[i], l),
              onDelete: () => widget.onDeleteTask(hp[i]),
              onMarkComplete: () => widget.onTaskCompleted(hp[i]),
            ),
            separatorBuilder: (_, __) => SizedBox(height: AppH.h12),
          ),
        ],
      ),
    );
  }

  String _greeting(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return l.greetingMorning;
    if (h >= 12 && h < 17) return l.greetingAfternoon;
    return l.greetingEvening;
  }

  Future<void> _handleEdit(TaskModel task, AppLocalizations l) async {
    final updated = await Navigator.push<TaskModel>(
      context,
      MaterialPageRoute(builder: (_) => AddTaskScreen(taskToEdit: task)),
    );
    if (updated != null) {
      widget.onEditTask(updated);
      _showReminderSnackbar(updated, l.taskUpdated, l);
    }
  }

  void _showReminderSnackbar(
    TaskModel task,
    String action,
    AppLocalizations l,
  ) {
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
        content: Text('$action. ${l.reminderIn} $timeStr.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
