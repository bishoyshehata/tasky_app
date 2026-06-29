import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasky/data/models/task_model.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.onChanged,
  });
  final TaskModel task;
  final int index;
  final VoidCallback onChanged;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xff282828),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: widget.task.isDone,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),

            onChanged: (value) {
              setState(() {
                widget.task.isDone = value!;
              });
              widget.onChanged();
            },
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
                        capitalize(widget.task.taskName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.task.isDone
                              ? Color(0xffA0A0A0)
                              : Color(0xffFFFCFC),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          decoration: widget.task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: Color(0xffA0A0A0),
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                  ],
                ),

                if (widget.task.taskDescription != '') ...[
                  Text(
                    capitalize(widget.task.taskDescription),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.task.isDone
                          ? Color(0xffA0A0A0)
                          : Color(0xffC6C6C6),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      decoration: widget.task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: Color(0xffA0A0A0),
                      decorationThickness: 1,
                    ),
                  ),
                ] else
                  SizedBox.shrink(),
                Text(
                  DateFormat(
                    'dd MMM yyyy • hh:mm a',
                  ).format(DateTime.parse(widget.task.dateTime)),
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

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
