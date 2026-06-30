import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasky/data/models/task_model.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
    this.onMarkComplete,
    this.onArchive,
    this.isReadOnly = false,
  });

  final TaskModel task;
  final int index;
  final bool isReadOnly;

  /// Called whenever isDone is toggled — triggers a save in the parent.
  final VoidCallback onChanged;

  /// Called when the user confirms deletion — parent handles list update
  /// and notification cancellation.
  final VoidCallback onDelete;

  /// Called when the user taps edit.
  final VoidCallback onEdit;

  /// Called when isDone changes to true — parent cancels the reminder.
  final VoidCallback? onMarkComplete;

  /// Called when user taps "Archive" from the more menu.
  final VoidCallback? onArchive;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = widget.task.isDone;
    final activeColor = colorScheme.onSurface;
    final doneColor = colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Checkbox ──────────────────────────────────────────
          if (!widget.isReadOnly)
            Checkbox(
              value: isDone,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              onChanged: (value) {
                setState(() {
                  widget.task.isDone = value!;
                  widget.task.completedAt = value ? DateTime.now() : null;
                });
                widget.onChanged();
                if (value == true) widget.onMarkComplete?.call();
              },
            )
          else
            const SizedBox(width: 12),

          // ── Text content ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  _capitalize(widget.task.taskName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDone ? doneColor : activeColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration:
                        isDone ? TextDecoration.lineThrough : null,
                    decorationColor: doneColor,
                    decorationThickness: 2,
                  ),
                ),

                // Description
                if (widget.task.taskDescription.isNotEmpty) ...[
                  Text(
                    _capitalize(widget.task.taskDescription),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDone ? doneColor : colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      decoration:
                          isDone ? TextDecoration.lineThrough : null,
                      decorationColor: doneColor,
                      decorationThickness: 1,
                    ),
                  ),
                ],

                // Date + reminder badge
                Row(
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy • hh:mm a')
                          .format(DateTime.parse(widget.task.dateTime)),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.task.reminderEnabled &&
                        widget.task.reminderDate != null) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.alarm,
                        size: 13,
                        color: widget.task.reminderDate!.isBefore(DateTime.now())
                            ? colorScheme.onSurfaceVariant.withOpacity(0.6)
                            : colorScheme.primary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        DateFormat('hh:mm a')
                            .format(widget.task.reminderDate!),
                        style: TextStyle(
                          color: widget.task.reminderDate!.isBefore(DateTime.now())
                              ? colorScheme.onSurfaceVariant.withOpacity(0.6)
                              : colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // ── More menu ─────────────────────────────────────────
          if (!widget.isReadOnly)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 24,
                color: colorScheme.onSurfaceVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'edit') widget.onEdit();
                if (value == 'delete') _confirmDelete(context);
                if (value == 'archive') widget.onArchive?.call();
              },
              itemBuilder: (_) => [
                if (widget.onArchive != null && widget.task.isDone)
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(Icons.archive_outlined,
                            color: colorScheme.onSurface, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Archive',
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          color: colorScheme.onSurface, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Edit',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          color: colorScheme.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Delete "${widget.task.taskName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete();
            },
            child: Text(
              'Delete',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
