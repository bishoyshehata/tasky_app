import 'package:flutter/material.dart';
import 'package:tasky/presentation/screens/comleted_tasks.dart';
import 'package:tasky/presentation/screens/home_screen.dart';
import 'package:tasky/presentation/screens/profile_screen.dart';
import 'package:tasky/presentation/screens/to_do_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tasky/data/models/task_model.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  List<TaskModel> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks');
    if (tasksJson != null) {
      setState(() {
        tasks = tasksJson
            .map((taskJson) => TaskModel.fromJson(jsonDecode(taskJson)))
            .toList();
      });
    }
  }

  void _saveAllTasks(List<TaskModel> updatedTasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = updatedTasks
        .map((task) => jsonEncode(task.toJson()))
        .toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  void _onTasksChanged(List<TaskModel> updatedTasks) {
    setState(() {
      tasks = updatedTasks;
    });
    _saveAllTasks(updatedTasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xff282828),
        type: BottomNavigationBarType.fixed,

        selectedItemColor: Color(0xff15B86C),
        unselectedItemColor: Color(0xffC6C6C6),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
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
          HomeScreen(tasks: tasks, onTasksChanged: _onTasksChanged),
          TodoScreen(tasks: tasks, onTasksChanged: _onTasksChanged),
          CompletedTasksScreen(tasks: tasks, onTasksChanged: _onTasksChanged),
          ProfileScreen(),
        ],
      ),
    );
  }
}
