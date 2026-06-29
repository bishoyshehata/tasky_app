import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasky/data/models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  bool _isHighPriority = false;
  bool _reminderEnabled = false;
  DateTime? _reminderDate;

  @override
  void dispose() {
    _nameFocus.dispose();
    _descFocus.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ── Reminder picker ──────────────────────────────────────────
  Future<void> _pickReminder() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null || !mounted) return;

    final combined = DateTime(
      date.year, date.month, date.day, time.hour, time.minute,
    );

    setState(() {
      _reminderDate = combined;
      _reminderEnabled = true;
    });
  }

  void _clearReminder() {
    setState(() {
      _reminderEnabled = false;
      _reminderDate = null;
    });
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                      // ── Task Name ────────────────────────────
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
                        focusNode: _nameFocus,
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Finish UI design for login screen',
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Please enter your task name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ── Task Description ─────────────────────
                      const Text(
                        'Task Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        focusNode: _descFocus,
                        textInputAction: TextInputAction.done,
                        maxLines: 5,
                        controller: _descController,
                        decoration: const InputDecoration(
                          hintText:
                              'Finish onboarding UI and hand off to devs by Thursday.',
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── High Priority ────────────────────────
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
                            value: _isHighPriority,
                            onChanged: (v) =>
                                setState(() => _isHighPriority = v),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Reminder ─────────────────────────────
                      const Text(
                        'Reminder',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // None option
                          Expanded(
                            child: _ReminderOption(
                              label: 'None',
                              isSelected: !_reminderEnabled,
                              onTap: _clearReminder,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Pick Date & Time option
                          Expanded(
                            child: _ReminderOption(
                              label: 'Pick Date & Time',
                              isSelected: _reminderEnabled,
                              onTap: _pickReminder,
                            ),
                          ),
                        ],
                      ),

                      // Show chosen date
                      if (_reminderEnabled && _reminderDate != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.alarm,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  DateFormat('dd MMM yyyy • hh:mm a')
                                      .format(_reminderDate!),
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _clearReminder,
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Save Button ──────────────────────────────────
              ElevatedButton.icon(
                onPressed: _submit,
                label: const Text('Add Task', style: TextStyle(fontSize: 14)),
                icon: const Icon(Icons.add),
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(346, 40),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Validate reminder not in the past
    if (_reminderEnabled && _reminderDate != null) {
      if (_reminderDate!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder time cannot be in the past.'),
          ),
        );
        return;
      }
    }

    final task = TaskModel(
      taskName: _nameController.text.trim(),
      taskDescription: _descController.text.trim(),
      isHighPriority: _isHighPriority,
      dateTime: DateTime.now().toIso8601String(),
      reminderDate: _reminderEnabled ? _reminderDate : null,
      reminderEnabled: _reminderEnabled,
    );

    if (mounted) Navigator.pop(context, task);
  }
}

// ── Reminder option chip ──────────────────────────────────────
class _ReminderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReminderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
