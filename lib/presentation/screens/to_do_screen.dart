import 'package:flutter/material.dart';
import 'package:tasky/data/models/task_model.dart';
import 'package:tasky/presentation/components/tasks_card.dart';

class TodoScreen extends StatefulWidget {
  final List<TaskModel> tasks;
  final ValueChanged<List<TaskModel>> onTasksChanged;

  const TodoScreen({
    super.key,
    required this.tasks,
    required this.onTasksChanged,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'To Do Tasks',
          style: TextStyle(color: Color(0xffFFFCFC), fontSize: 20),
        ),
        backgroundColor: const Color(0xFF121212),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 12.0, right: 12.0),
        child: buildTaskCards(),
      ),
    );
  }

  Widget buildTaskCards() {
    final todoTasks = widget.tasks.where((task) => !task.isDone).toList();

    if (todoTasks.isEmpty) {
      return Center(
        child: Text(
          'No Tasks Yet',
          style: TextStyle(color: Colors.white54, fontSize: 18),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.only(bottom: 65),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: todoTasks.length,
          itemBuilder: (context, index) {
            return TaskCard(
              task: todoTasks[index],
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
}
