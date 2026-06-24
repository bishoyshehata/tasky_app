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

Future<void> _loadUserName() async {

final prefs = await SharedPreferences.getInstance();

setState(() {

name = prefs.getString('name') ?? '';

});

}

Future<void> _loadTasks() async {

final prefs = await SharedPreferences.getInstance();

final tasksJson = prefs.getStringList('tasks');

setState(() {

tasks = tasksJson != null

? tasksJson

.map((e) => TaskModel.fromJson(jsonDecode(e)))

.toList()

: [];

});

}

📌 الجزء الثاني (UI)

dart

@override

Widget build(BuildContext context) {

return Scaffold(

backgroundColor: const Color(0xFF181818),

body: SafeArea(

child: Padding(

padding: const EdgeInsets.all(16),

child: SingleChildScrollView(

child: Column(

crossAxisAlignment: CrossAxisAlignment.start,

children: [

// Header

Row(

children: [

const CircleAvatar(

radius: 25,

backgroundImage: AssetImage(

'assets/images/file.jpg',

),

),

const SizedBox(width: 12),

Expanded(

child: Column(

crossAxisAlignment: CrossAxisAlignment.start,

children: [

Text(

'Good Evening, $name',

style: const TextStyle(

color: Colors.white,

fontSize: 18,

fontWeight: FontWeight.bold,

),

),

const SizedBox(height: 4),

const Text(

'One task at a time. One step closer.',

style: TextStyle(

color: Color(0xffC6C6C6),

fontSize: 14,

),

),

],

),

),

IconButton.filled(

style: IconButton.styleFrom(

backgroundColor: const Color(0xff282828),

),

onPressed: () {},

icon: const Icon(

Icons.light_mode,

color: Colors.white,

),

),

],

),

const SizedBox(height: 24),

// Welcome Text

const Text(

'Yuhuu, Your work is',

style: TextStyle(

color: Colors.white,

fontSize: 30,

fontWeight: FontWeight.bold,

),

),

Row(

children: [

const Text(

'almost done!',

style: TextStyle(

color: Colors.white,

fontSize: 30,

fontWeight: FontWeight.bold,

),

),

const SizedBox(width: 8),

SvgPicture.asset(

'assets/images/hand.svg',

width: 36,

height: 36,

),

],

),

const SizedBox(height: 24),

// Achieved Tasks Card

AchievedTasks(

allTasks: tasks.length,

achievedTasks: tasks.where((e) => e.isDone).length,

),

const SizedBox(height: 24),

// High Priority Tasks

if (tasks.any((e) => e.isHighPriority)) ...[

const Text(

'🔥 High Priority Tasks',

style: TextStyle(

color: Colors.white,

fontSize: 22,

fontWeight: FontWeight.bold,

),

),

const SizedBox(height: 16),

buildHighPriorityCards(),

const SizedBox(height: 24),

],

// All Tasks

const Text(

'📋 All Tasks',

style: TextStyle(

color: Colors.white,

fontSize: 22,

fontWeight: FontWeight.bold,

),

),

const SizedBox(height: 16),

buildTaskCards(),

const SizedBox(height: 100),

],

),

),

),

),

floatingActionButton: SizedBox(

height: 45,

child: FloatingActionButton.extended(

onPressed: () async {

await Navigator.push(

context,

MaterialPageRoute(

builder: (_) => const AddTaskScreen(),

),

);

_loadTasks();

},

backgroundColor: const Color(0xff15B86C),

foregroundColor: Colors.white,

label: const Text(

'Add New Task',

style: TextStyle(

fontSize: 14,

fontWeight: FontWeight.w600,

),

),

icon: const Icon(Icons.add),

shape: RoundedRectangleBorder(

borderRadius: BorderRadius.circular(30),

),

),

),

);

}

📌 الجزء الثالث (Functions)

dart

Widget buildTaskCards() {

final reversedTasks = tasks.reversed.toList();

if (reversedTasks.isEmpty) {

return const Center(

child: Padding(

padding: EdgeInsets.symmetric(vertical: 40),

child: Text(

'No Tasks Yet 🚀',

style: TextStyle(

color: Colors.white54,

fontSize: 18,

fontWeight: FontWeight.w500,

),

),

),

);

}

return ListView.separated(

shrinkWrap: true,

physics: const NeverScrollableScrollPhysics(),

itemCount: reversedTasks.length,

itemBuilder: (context, index) {

return TaskCard(

task: reversedTasks[index],

index: index,

onChanged: _loadTasks,

);

},

separatorBuilder: (_, __) => const SizedBox(height: 12),

);

}

Widget buildHighPriorityCards() {

final highPriorityTasks = tasks

.where((task) => task.isHighPriority)

.toList()

.reversed

.toList();

return ListView.separated(

shrinkWrap: true,

physics: const NeverScrollableScrollPhysics(),

itemCount: highPriorityTasks.length,

itemBuilder: (context, index) {

return TaskCard(

task: highPriorityTasks[index],

index: index,

onChanged: _loadTasks,

);

},

separatorBuilder: (_, __) => const SizedBox(height: 12),

);

}

}