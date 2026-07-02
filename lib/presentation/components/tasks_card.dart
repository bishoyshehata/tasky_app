import 'package:engez/core/theme/app_sizes.dart';
import 'package:engez/data/models/task_model.dart';
import 'package:engez/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _startTimerIfNeeded();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimerIfNeeded() {
    _timer?.cancel();
    if (widget.task.reminderEnabled && widget.task.reminderDate != null) {
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final isDone = widget.task.isDone;
    final activeColor = colorScheme.onSurface;
    final doneColor = colorScheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppW.w6, vertical: AppH.h2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppR.r20),
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
                borderRadius: BorderRadius.circular(AppR.r5),
              ),
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
            SizedBox(width: AppW.w12),

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
                    fontSize: AppSp.sp16,
                    fontWeight: FontWeight.w400,
                    decoration: isDone ? TextDecoration.lineThrough : null,
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
                      fontSize: AppSp.sp14,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: doneColor,
                      decorationThickness: 1,
                    ),
                  ),
                ],

                // Date + reminder badge
                Row(
                  children: [
                    Text(
                      DateFormat(
                        'dd MMM yyyy • hh:mm a',
                      ).format(DateTime.parse(widget.task.dateTime)),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: AppSp.sp12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.task.reminderEnabled &&
                        widget.task.reminderDate != null) ...[
                      SizedBox(width: AppW.w6),
                      Icon(
                        Icons.alarm,
                        size: AppSp.sp13,
                        color:
                            widget.task.reminderDate!.isBefore(DateTime.now())
                            ? colorScheme.onSurfaceVariant.withOpacity(0.6)
                            : colorScheme.primary,
                      ),
                      SizedBox(width: AppW.w2),
                      Text(
                        DateFormat('hh:mm a').format(widget.task.reminderDate!),
                        style: TextStyle(
                          color:
                              widget.task.reminderDate!.isBefore(DateTime.now())
                              ? colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                )
                              : colorScheme.primary,
                          fontSize: AppSp.sp11,
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
                size: AppSp.sp24,
                color: colorScheme.onSurfaceVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppR.r12),
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
                        Icon(
                          Icons.archive_outlined,
                          color: colorScheme.onSurface,
                          size: AppSp.sp20,
                        ),
                        SizedBox(width: AppW.w8),
                        Text(
                          l.taskActionArchive,
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: colorScheme.onSurface,
                        size: AppSp.sp20,
                      ),
                      SizedBox(width: AppW.w8),
                      Text(
                        l.taskActionEdit,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                        size: AppSp.sp20,
                      ),
                      SizedBox(width: AppW.w8),
                      Text(
                        l.taskActionDelete,
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
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteTaskTitle),
        content: Text(l.deleteTaskDesc(widget.task.taskName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete();
            },
            child: Text(
              l.deleteTaskConfirm,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
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
