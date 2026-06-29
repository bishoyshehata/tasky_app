import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:tasky/core/theme/app_theme_notifier.dart';
import 'package:tasky/data/models/task_model.dart';
import 'package:tasky/data/models/user_model.dart';
import 'package:tasky/presentation/components/achieved_tasks.dart';
import 'package:tasky/presentation/components/tasks_card.dart';
import 'package:tasky/presentation/screens/add_task._screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  final List<TaskModel> tasks;
  final ValueChanged<List<TaskModel>> onTasksChanged;
  final UserModel? userModel;

  const HomeScreen({
    super.key,
    required this.tasks,
    required this.onTasksChanged,
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
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          widget.userModel?.profileImagePath != null
                          ? FileImage(File(widget.userModel!.profileImagePath!))
                          : const AssetImage('assets/images/file.jpg')
                                as ImageProvider,
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            '${getGreeting()}, ${widget.userModel?.name ?? ''} ',
                            style: const TextStyle(fontSize: 18),
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
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () {
                        AppThemeNotifier.instance.toggle();
                      },
                      icon: ValueListenableBuilder<ThemeMode>(
                        valueListenable: AppThemeNotifier.instance,
                        builder: (_, themeMode, __) {
                          final isDark = themeMode == ThemeMode.dark;

                          return Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Yuhuu ,Your work Is ',
                  style: TextStyle(fontSize: 30),
                ),
                Row(
                  children: [
                    const Text(
                      'almost done ! ',
                      style: TextStyle(fontSize: 30),
                    ),
                    SvgPicture.asset(
                      'assets/images/hand.svg',
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AchievedTasks(
                  allTasks: widget.tasks.length,
                  achievedTasks: widget.tasks
                      .where((task) => task.isDone)
                      .length,
                ),
                const SizedBox(height: 10),
                buildHighPrioritySection(context),
                const SizedBox(height: 10),
                buildTaskCards(context),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        height: 40,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTaskScreen()),
            );

            if (result is TaskModel) {
              final updatedTasks = List<TaskModel>.from(widget.tasks)
                ..add(result);
              widget.onTasksChanged(updatedTasks);
            }
          },
          label: const Text(
            'Add New Task',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget buildTaskCards(BuildContext context) {
    final reversedTasks = widget.tasks
        .where((task) => !task.isHighPriority)
        .toList()
        .reversed
        .toList();

    if (reversedTasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Text(
            'No Tasks Yet',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            'My Tasks',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 65),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reversedTasks.length,
          itemBuilder: (context, index) {
            return TaskCard(
              task: reversedTasks[index],
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

  Widget buildHighPrioritySection(BuildContext context) {
    final highPriorityTasks = widget.tasks
        .where((task) => task.isHighPriority)
        .toList()
        .reversed
        .toList();

    if (highPriorityTasks.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
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
          const SizedBox(height: 6),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: highPriorityTasks.length,
            itemBuilder: (context, index) {
              return TaskCard(
                task: highPriorityTasks[index],
                index: index,
                onChanged: () {
                  widget.onTasksChanged(widget.tasks);
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          ),
        ],
      ),
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
