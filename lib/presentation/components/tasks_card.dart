import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasky/data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task});
  final TaskModel task;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xff282828),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),

            onChanged: (value) {},
            activeColor: const Color(0xff15B86C),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.taskName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xffFFFCFC),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                Text(
                  task.taskDescription,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xffC6C6C6),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  DateFormat(
                    'dd MMM yyyy • hh:mm a',
                  ).format(DateTime.parse(task.dateTime)),
                  style: TextStyle(
                    color: Color(0xffC6C6C6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              size: 30,
              color: Color(0xffA0A0A0),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
