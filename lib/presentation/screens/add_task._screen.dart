import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/data/models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  final FocusNode taskNameFocus = FocusNode();
  final FocusNode taskDescriptionFocus = FocusNode();

  bool isHighPriority = true;
  @override
  void dispose() {
    taskNameFocus.dispose();
    taskDescriptionFocus.dispose();
    taskNameController.dispose();
    taskDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181818),
        iconTheme: IconThemeData(color: Color(0xffFFFCFC)),
        title: Text(
          "New Task",
          style: TextStyle(color: Color(0xffFFFCFC), fontSize: 20),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Name',
                        style: TextStyle(
                          color: Color(0xffFFFCFC),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        textInputAction: TextInputAction.next,

                        focusNode: taskNameFocus,
                        controller: taskNameController,
                        cursorColor: Colors.white,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Color(0xFF282828),
                          filled: true,
                          hintText: 'Finish UI design for login screen',
                          hintStyle: TextStyle(
                            color: Color(0xFF6D6D6D),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? false) {
                            return 'Please Enter Your Task Name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Task Description',
                        style: TextStyle(
                          color: Color(0xffFFFCFC),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        focusNode: taskDescriptionFocus,
                        textInputAction: TextInputAction.done,
                        maxLines: 5,
                        controller: taskDescriptionController,
                        cursorColor: Colors.white,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Color(0xFF282828),
                          filled: true,
                          hintText:
                              'Finish onboarding UI and hand off to devs by Thursday.',
                          hintStyle: TextStyle(
                            color: Color(0xFF6D6D6D),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        // validator: (value) {
                        //   if (value?.trim().isEmpty ?? false) {
                        //     return 'Please Enter The Task Description';
                        //   }
                        //   return null;
                        // },
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'High Priority',
                            style: TextStyle(
                              color: Color(0xffFFFCFC),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Switch(
                            value: isHighPriority,
                            onChanged: (value) {
                              isHighPriority = value;
                              setState(() {});
                            },
                            activeTrackColor: Color(0xFF15B86C),
                            activeThumbColor: Color(0xFFFFFCFC),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              ElevatedButton.icon(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    String taskName = taskNameController.text;
                    String taskDescription = taskDescriptionController.text;
                    bool isHighPriorityVal = isHighPriority;
                    final task = TaskModel(
                      taskName: taskName,
                      taskDescription: taskDescription,
                      isHighPriority: isHighPriorityVal,
                      dateTime: DateTime.now().toIso8601String(),
                    );
                    final prefs = await SharedPreferences.getInstance();
                    final tasksJson = prefs.getStringList('tasks');
                    List<TaskModel> tasksList = [];
                    if (tasksJson != null) {
                      tasksList = tasksJson
                          .map(
                            (taskJson) =>
                                TaskModel.fromJson(jsonDecode(taskJson)),
                          )
                          .toList();
                    }
                    tasksList.add(task);

                    final updatedTasksJson = tasksList
                        .map((task) => jsonEncode(task.toJson()))
                        .toList();
                    await prefs.setStringList('tasks', updatedTasksJson);

                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  }
                },
                label: Text('Add Task', style: TextStyle(fontSize: 14)),

                icon: Icon(Icons.add),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF15B86C),
                  foregroundColor: Color(0xffFFFCFC),
                  fixedSize: Size(346, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
