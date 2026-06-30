import 'package:flutter/material.dart';
import 'package:engez/core/notifications/local_notification_service.dart';
import 'package:engez/domain/usecases/cancel_task_reminder_use_case.dart';
import 'package:engez/domain/usecases/schedule_task_reminder_use_case.dart';
import 'package:engez/domain/usecases/update_task_reminder_use_case.dart';
import 'package:engez/l10n/app_localizations.dart';
import 'package:engez/presentation/screens/comleted_tasks.dart';
import 'package:engez/presentation/screens/home_screen.dart';
import 'package:engez/presentation/screens/profile_screen.dart';
import 'package:engez/presentation/screens/to_do_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:engez/data/models/task_model.dart';
import 'package:engez/data/models/user_model.dart';
import 'package:engez/core/backup/auto_backup_manager.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  static final ValueNotifier<bool> refreshTrigger = ValueNotifier(false);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  List<TaskModel> tasks = [];
  UserModel? userModel;

  // ── Use Cases ────────────────────────────────────────────────
  late final _scheduleUseCase =
      ScheduleTaskReminderUseCase(LocalNotificationService.instance);
  late final _cancelUseCase =
      CancelTaskReminderUseCase(LocalNotificationService.instance);
  late final _updateUseCase =
      UpdateTaskReminderUseCase(LocalNotificationService.instance);

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadTasksAndReschedule();
    MainNavigationScreen.refreshTrigger.addListener(_onGlobalRefresh);
    AutoBackupManager.checkAndRun();
  }

  @override
  void dispose() {
    MainNavigationScreen.refreshTrigger.removeListener(_onGlobalRefresh);
    super.dispose();
  }

  void _onGlobalRefresh() {
    if (mounted) {
      _loadTasksAndReschedule();
    }
  }

  // ── Data ─────────────────────────────────────────────────────
  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null && mounted) {
      setState(() {
        userModel = UserModel.fromJson(jsonDecode(userJson));
      });
    }
  }

  Future<void> _loadTasksAndReschedule() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks');
    if (tasksJson != null && mounted) {
      List<TaskModel> loaded = tasksJson
          .map((j) => TaskModel.fromJson(jsonDecode(j)))
          .toList();

      // ── Auto-Archive & Cleanup Logic ────────────────────────
      final now = DateTime.now();
      bool needsSave = false;

      for (int i = 0; i < loaded.length; i++) {
        final task = loaded[i];

        // 1. Auto-delete after 7 days in archive
        if (task.isArchived) {
          if (task.archivedAt != null) {
            final diff = now.difference(task.archivedAt!);
            if (diff.inDays >= 7) {
              continue; // filter out below
            }
          }
        }
        // 2. Auto-archive after 24 hours of being done
        else if (task.isDone) {
          if (task.completedAt != null) {
            final diff = now.difference(task.completedAt!);
            if (diff.inHours >= 24) {
              task.isArchived = true;
              task.archivedAt = now;
              needsSave = true;
            }
          } else {
            task.completedAt = now;
            needsSave = true;
          }
        }
      }

      // Filter out tasks that should be permanently deleted
      final originalCount = loaded.length;
      loaded = loaded.where((task) {
        if (task.isArchived && task.archivedAt != null) {
          return now.difference(task.archivedAt!).inDays < 7;
        }
        return true;
      }).toList();

      if (loaded.length != originalCount) {
        needsSave = true;
      }

      if (needsSave) {
        await _saveAllTasks(loaded);
      }

      setState(() => tasks = loaded);
      await _scheduleUseCase.rescheduleAll(loaded);
    }
  }

  Future<void> _saveAllTasks(List<TaskModel> updated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'tasks',
      updated.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }

  // ── Callbacks ─────────────────────────────────────────────────
  void _onTasksChanged(List<TaskModel> updated) {
    setState(() => tasks = updated);
    _saveAllTasks(updated);
  }

  Future<void> _onTaskAdded(TaskModel task) async {
    final updated = List<TaskModel>.from(tasks)..add(task);
    _onTasksChanged(updated);
    await _scheduleUseCase.execute(task);
  }

  Future<void> _onEditTask(TaskModel updatedTask) async {
    final updatedList =
        tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
    _onTasksChanged(updatedList);
    await _updateUseCase.execute(updatedTask);
  }

  Future<void> _onDeleteTask(TaskModel task) async {
    await _cancelUseCase.execute(task.id);
    final updated = tasks.where((t) => t.id != task.id).toList();
    _onTasksChanged(updated);
  }

  Future<void> _onTaskCompleted(TaskModel task) async {
    if (task.reminderEnabled) {
      await _cancelUseCase.execute(task.id);
    }
    _onTasksChanged(tasks);
  }

  void _onArchiveTask(TaskModel task) {
    final updatedList = tasks.map((t) {
      if (t.id == task.id) {
        return t.copyWith(isArchived: true, archivedAt: DateTime.now());
      }
      return t;
    }).toList();
    _onTasksChanged(updatedList);
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l.tabHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.format_list_numbered_rtl_outlined),
            label: l.tabToDo,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.done_all_rounded),
            label: l.tabCompleted,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_outlined),
            label: l.tabProfile,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            tasks: tasks.where((t) => !t.isArchived).toList(),
            onTasksChanged: _onTasksChanged,
            onTaskAdded: _onTaskAdded,
            onEditTask: _onEditTask,
            onDeleteTask: _onDeleteTask,
            onTaskCompleted: _onTaskCompleted,
            userModel: userModel,
          ),
          TodoScreen(
            tasks: tasks.where((t) => !t.isArchived).toList(),
            onTasksChanged: _onTasksChanged,
            onEditTask: _onEditTask,
            onDeleteTask: _onDeleteTask,
            onTaskCompleted: _onTaskCompleted,
          ),
          CompletedTasksScreen(
            tasks: tasks,
            onTasksChanged: _onTasksChanged,
            onEditTask: _onEditTask,
            onDeleteTask: _onDeleteTask,
            onTaskCompleted: _onTaskCompleted,
            onArchiveTask: _onArchiveTask,
          ),
          ProfileScreen(
            tasks: tasks,
            onUserChanged: _loadUser,
            onTasksChanged: _onTasksChanged,
          ),
        ],
      ),
    );
  }
}
