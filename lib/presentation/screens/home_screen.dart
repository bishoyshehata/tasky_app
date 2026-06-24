import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/data/models/task_model.dart';
import 'package:tasky/presentation/components/achieved_tasks.dart';
import 'package:tasky/presentation/components/tasks_card.dart';
import 'package:tasky/presentation/screens/add_task._screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskModel> tasks = [];
  String name = '';
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadTasks();
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
    });
  }

  void _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final tasksJson = prefs.getStringList('tasks');

    if (tasksJson != null) {
      setState(() {
        tasks = tasksJson != null
            ? tasksJson
                  .map((taskJson) => TaskModel.fromJson(jsonDecode(taskJson)))
                  .toList()
            : [];
      });
    }
  }

  void _saveAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/images/file.jpg'),
                    ),
                    SizedBox(width: 4),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Evening ,$name ',
                            style: TextStyle(
                              color: Color(0xffFFFCFC),
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'One task at a time.One step closer.',
                            style: TextStyle(
                              color: Color(0xffC6C6C6),
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Color(0xff282828),
                      ),
                      onPressed: () {},
                      icon: Icon(Icons.light_mode, color: Color(0xffFFFCFC)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Yuhuu ,Your work Is ',
                  style: TextStyle(color: Color(0xffFFFCFC), fontSize: 30),
                ),
                Row(
                  children: [
                    Text(
                      'almost done ! ',
                      style: TextStyle(color: Color(0xffFFFCFC), fontSize: 30),
                    ),
                    SvgPicture.asset(
                      'assets/images/hand.svg',
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                AchievedTasks(
                  allTasks: tasks.length,
                  achievedTasks: tasks.where((task) => task.isDone).length,
                ),
                SizedBox(height: 20),
                buildHighPrioritySection(),
                SizedBox(height: 20),
                buildTaskCards(),
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

            if (result == true) {
              _loadTasks();
            }
          },
          backgroundColor: const Color(0xff15B86C),
          foregroundColor: const Color(0xffFFFCFC),
          label: const Text(
            'Add New Task',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget buildTaskCards() {
    final reversedTasks = tasks
        .where((task) => !task.isHighPriority)
        .toList()
        .reversed
        .toList();
    if (reversedTasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'No Tasks Yet',
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Tasks',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xff15B86C),
          ),
        ),
        SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reversedTasks.length,
          itemBuilder: (context, index) {
            return TaskCard(
              task: reversedTasks[index],
              index: index,
              onChanged: () {
                setState(() {});
                _saveAllTasks();
              },
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
        ),
      ],
    );
  }

  buildHighPrioritySection() {
    List<TaskModel> highPriorityTasks = tasks
        .where((task) => task.isHighPriority)
        .toList()
        .reversed
        .toList();
    return highPriorityTasks.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'High Priority',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff15B86C),
                ),
              ),
              SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: highPriorityTasks.length,
                itemBuilder: (context, index) {
                  final task = highPriorityTasks[index];
                  return TaskCard(
                    task: task,
                    index: index,
                    onChanged: () {
                      setState(() {});
                      _saveAllTasks();
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 12);
                },
              ),
            ],
          )
        : SizedBox.shrink();
  }
}
