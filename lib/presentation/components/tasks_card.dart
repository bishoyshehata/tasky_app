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
    final colorScheme = Theme.of(context).colorScheme;

    // Semantic colours for done/active state — derived from theme
    final activeTextColor = colorScheme.onSurface;
    final doneTextColor = colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface,
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
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalize(widget.task.taskName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.task.isDone ? doneTextColor : activeTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration: widget.task.isDone
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: doneTextColor,
                    decorationThickness: 2,
                  ),
                ),
                if (widget.task.taskDescription != '') ...[
                  Text(
                    capitalize(widget.task.taskDescription),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.task.isDone
                          ? doneTextColor
                          : colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      decoration: widget.task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: doneTextColor,
                      decorationThickness: 1,
                    ),
                  ),
                ] else
                  const SizedBox.shrink(),
                Text(
                  DateFormat('dd MMM yyyy • hh:mm a')
                      .format(DateTime.parse(widget.task.dateTime)),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.more_vert,
            size: 30,
            color: colorScheme.onSurfaceVariant,
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
