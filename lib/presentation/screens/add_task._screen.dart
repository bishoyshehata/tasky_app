import 'package:flutter/material.dart';
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

  bool isHighPriority = false;

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
      appBar: AppBar(title: const Text('New Task')),
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
                      const Text(
                        'Task Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        focusNode: taskNameFocus,
                        controller: taskNameController,
                        decoration: const InputDecoration(
                          hintText: 'Finish UI design for login screen',
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? false) {
                            return 'Please Enter Your Task Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Task Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        focusNode: taskDescriptionFocus,
                        textInputAction: TextInputAction.done,
                        maxLines: 5,
                        controller: taskDescriptionController,
                        decoration: const InputDecoration(
                          hintText:
                              'Finish onboarding UI and hand off to devs by Thursday.',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'High Priority',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Switch(
                            value: isHighPriority,
                            onChanged: (value) {
                              setState(() {
                                isHighPriority = value;
                              });
                            },
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
                    final task = TaskModel(
                      taskName: taskNameController.text,
                      taskDescription: taskDescriptionController.text,
                      isHighPriority: isHighPriority,
                      dateTime: DateTime.now().toIso8601String(),
                    );
                    if (mounted) {
                      Navigator.pop(context, task);
                    }
                  }
                },
                label: const Text('Add Task', style: TextStyle(fontSize: 14)),
                icon: const Icon(Icons.add),
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(346, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
