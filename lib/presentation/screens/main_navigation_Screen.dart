import 'package:flutter/material.dart';
import 'package:tasky/core/notifications/local_notification_service.dart';
import 'package:tasky/domain/usecases/cancel_task_reminder_use_case.dart';
import 'package:tasky/domain/usecases/schedule_task_reminder_use_case.dart';
import 'package:tasky/domain/usecases/update_task_reminder_use_case.dart';
import 'package:tasky/presentation/screens/comleted_tasks.dart';
import 'package:tasky/presentation/screens/home_screen.dart';
import 'package:tasky/presentation/screens/profile_screen.dart';
import 'package:tasky/presentation/screens/to_do_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tasky/data/models/task_model.dart';
import 'package:tasky/data/models/user_model.dart';

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
      final loaded = tasksJson
          .map((j) => TaskModel.fromJson(jsonDecode(j)))
          .toList();
      setState(() => tasks = loaded);
      // Restore reminders that survived a reboot / app kill
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

  // ── Callbacks passed to child screens ────────────────────────

  void _onTasksChanged(List<TaskModel> updated) {
    setState(() => tasks = updated);
    _saveAllTasks(updated);
  }

  /// Called after a new task is created — schedules its reminder if needed.
  Future<void> _onTaskAdded(TaskModel task) async {
    final updated = List<TaskModel>.from(tasks)..add(task);
    _onTasksChanged(updated);
    await _scheduleUseCase.execute(task);
  }

  /// Called when a task is edited.
  Future<void> _onEditTask(TaskModel updatedTask) async {
    final updatedList = tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
    _onTasksChanged(updatedList);
    await _updateUseCase.execute(updatedTask);
  }

  /// Called when the user taps the delete button on a task card.
  Future<void> _onDeleteTask(TaskModel task) async {
    // Cancel reminder first
    await _cancelUseCase.execute(task.id);
    // Then remove from list
    final updated = tasks.where((t) => t.id != task.id).toList();
    _onTasksChanged(updated);
  }

  /// Called when a task is marked as completed.
  Future<void> _onTaskCompleted(TaskModel task) async {
    if (task.reminderEnabled) {
      await _cancelUseCase.execute(task.id);
    }
    // Trigger a save so isDone is persisted
    _onTasksChanged(tasks);
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered_rtl_outlined),
            label: 'To Do',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done_all_rounded),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_outlined),
            label: 'Profile',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            tasks: tasks,
            onTasksChanged: _onTasksChanged,
            onTaskAdded: _onTaskAdded,
            onEditTask: _onEditTask,
            onDeleteTask: _onDeleteTask,
            onTaskCompleted: _onTaskCompleted,
            userModel: userModel,
          ),
          TodoScreen(
            tasks: tasks,
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
          ),
          ProfileScreen(onUserChanged: _loadUser),
        ],
      ),
    );
  }
}
