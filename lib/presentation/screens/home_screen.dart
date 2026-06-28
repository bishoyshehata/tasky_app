import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/data/models/task_model.dart';
import 'package:tasky/data/models/user_model.dart';
import 'package:tasky/presentation/components/achieved_tasks.dart';
import 'package:tasky/presentation/components/tasks_card.dart';
import 'package:tasky/presentation/screens/add_task._screen.dart';

class HomeScreen extends StatefulWidget {
  final List<TaskModel> tasks;
  final ValueChanged<List<TaskModel>> onTasksChanged;

  const HomeScreen({
    super.key,
    required this.tasks,
    required this.onTasksChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? userModel;
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final userJson = prefs.getString('user');
      if (userJson != null) {
        userModel = UserModel.fromJson(jsonDecode(userJson));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
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
                            'Good Evening , ${userModel?.name ?? ''} ',
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
                SizedBox(height: 10),
                AchievedTasks(
                  allTasks: widget.tasks.length,
                  achievedTasks: widget.tasks
                      .where((task) => task.isDone)
                      .length,
                ),
                SizedBox(height: 10),
                buildHighPrioritySection(),
                SizedBox(height: 10),
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

            if (result is TaskModel) {
              final updatedTasks = List<TaskModel>.from(widget.tasks)
                ..add(result);
              widget.onTasksChanged(updatedTasks);
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
    final reversedTasks = widget.tasks
        .where((task) => !task.isHighPriority)
        .toList()
        .reversed
        .toList();
    if (reversedTasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
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
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'My Tasks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.only(bottom: 65),
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

  buildHighPrioritySection() {
    List<TaskModel> highPriorityTasks = widget.tasks
        .where((task) => task.isHighPriority)
        .toList()
        .reversed
        .toList();
    return highPriorityTasks.isNotEmpty
        ? Container(
            decoration: BoxDecoration(
              color: Color(0xff282828),
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
                      color: Color(0xff15B86C),
                    ),
                  ),
                ),
                SizedBox(height: 6),
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
                        widget.onTasksChanged(widget.tasks);
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 12);
                  },
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }
}
