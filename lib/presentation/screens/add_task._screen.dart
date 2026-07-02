import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:engez/data/models/task_model.dart';
import 'package:engez/data/models/alarm_sound_model.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_system_ringtones/flutter_system_ringtones.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:engez/core/theme/app_sizes.dart';
import 'package:engez/l10n/app_localizations.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskModel? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  static const _pickerChannel = MethodChannel('com.bsh.tasky/ringtone_picker');
  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<String> _getRealIosPath(String savedPath, String name) async {
    if (Platform.isIOS) {
      final libDir = await getLibraryDirectory();
      final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9.\-_]'), '_');
      return '${libDir.path}/Sounds/$safeName';
    }
    return savedPath;
  }

  Future<T?> _safeInvokeMethod<T>(String method, [dynamic arguments]) async {
    if (Platform.isAndroid) {
      try {
        return await _pickerChannel.invokeMethod<T>(method, arguments);
      } catch (e) {
        debugPrint('MethodChannel error: $e');
      }
    } else if (Platform.isIOS) {
      try {
        if (method == 'playRingtone') {
          final uri = arguments?['uri'] as String?;
          if (uri != null && uri != 'default') {
            await _audioPlayer.stop();
            await _audioPlayer.play(DeviceFileSource(uri));
          }
        } else if (method == 'stopRingtone') {
          await _audioPlayer.stop();
        }
      } catch (e) {
        debugPrint('AudioPlayer error: $e');
      }
    }
    return null;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  bool _isHighPriority = false;
  bool _reminderEnabled = false;
  DateTime? _reminderDate;
  String _alarmSound = 'default';
  int _snoozeDuration = 10;

  List<String> _customSounds = [];

  @override
  void initState() {
    super.initState();
    _loadLastSelectedSound();
    _loadCustomSounds();
    if (widget.taskToEdit != null) {
      _nameController.text = widget.taskToEdit!.taskName;
      _descController.text = widget.taskToEdit!.taskDescription;
      _isHighPriority = widget.taskToEdit!.isHighPriority;
      _reminderEnabled = widget.taskToEdit!.reminderEnabled;
      _reminderDate = widget.taskToEdit!.reminderDate;
      _alarmSound = widget.taskToEdit!.alarmSound;
      _snoozeDuration = widget.taskToEdit!.snoozeDuration;
    }
  }

  Future<void> _loadCustomSounds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customSounds = prefs.getStringList('custom_user_sounds') ?? [];
    });
  }

  Future<void> _saveCustomSound(String soundKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_customSounds.contains(soundKey)) {
      _customSounds.add(soundKey);
      await prefs.setStringList('custom_user_sounds', _customSounds);
      setState(() {});
    }
  }

  Future<void> _deleteCustomSound(String item) async {
    final prefs = await SharedPreferences.getInstance();
    _customSounds.remove(item);
    await prefs.setStringList('custom_user_sounds', _customSounds);
    setState(() {});
  }

  Future<void> _loadLastSelectedSound() async {
    if (widget.taskToEdit == null) {
      final prefs = await SharedPreferences.getInstance();
      final lastSound = prefs.getString('last_selected_alarm_sound');
      if (lastSound != null) {
        setState(() {
          _alarmSound = lastSound;
        });
      }
    }
  }

  Future<void> _saveSelectedSound(String soundData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_selected_alarm_sound', soundData);
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _descFocus.dispose();
    _nameController.dispose();
    _descController.dispose();
    _audioPlayer.dispose();
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
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
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

  Future<void> _showRingtonePicker() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    List<Ringtone> systemSounds = [];
    try {
      final ringtones = await FlutterSystemRingtones.getRingtoneSounds();
      final alarms = await FlutterSystemRingtones.getAlarmSounds();

      final seen = <String>{};
      systemSounds = [
        ...ringtones,
        ...alarms,
      ].where((s) => seen.add(s.uri)).toList();
    } catch (e) {
      // ignore
    }

    if (mounted) Navigator.pop(context);
    if (!mounted) return;

    String tempSelectedSound = _alarmSound;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppR.r16)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(AppW.w16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context).taskAlarmSound,
                          style: TextStyle(
                            fontSize: AppSp.sp18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Add custom sound button
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(AppW.w8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: colorScheme.primary),
                    ),
                    title: Text(
                      AppLocalizations.of(context).addCustomSound,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      try {
                        final result = await FilePicker.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: [
                            'mp3',
                            'wav',
                            'm4a',
                            'aac',
                            'ogg',
                          ],
                        );
                        if (result != null &&
                            result.files.single.path != null) {
                          final path = result.files.single.path!;
                          var name = result.files.single.name;

                          String finalPath = path;
                          if (Platform.isAndroid) {
                            final appDir = await getApplicationSupportDirectory();
                            final soundsDir = Directory('${appDir.path}/Sounds');
                            if (!await soundsDir.exists()) {
                              await soundsDir.create(recursive: true);
                            }
                            final safeName = name.replaceAll(
                              RegExp(r'[^a-zA-Z0-9.\-_]'),
                              '_',
                            );
                            final newPath = '${soundsDir.path}/$safeName';
                            await File(path).copy(newPath);
                            finalPath = newPath;
                            name = safeName;
                          } else if (Platform.isIOS) {
                            final String? wavPath = await const MethodChannel(
                                    'com.bsh.tasky/audio_converter')
                                .invokeMethod<String>('convertToWav', {
                              'sourcePath': path,
                              'destFileName': name,
                            });
                            if (wavPath != null) {
                              finalPath = wavPath;
                              name = wavPath.split('/').last;
                            } else {
                              throw Exception('Audio conversion failed');
                            }
                          }

                          final soundModel = AlarmSoundModel(
                            type: AlarmSoundType.custom,
                            uri: finalPath,
                            fileName: name,
                            title: name.split('.').first,
                          );
                          final soundKey = soundModel.toKey();

                          await _saveCustomSound(soundKey);
                          setSheetState(() {
                            tempSelectedSound = soundKey;
                          });
                          await _safeInvokeMethod('playRingtone', {
                            'uri': finalPath,
                          });
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${AppLocalizations.of(context).errorPickingFile}: $e',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),

                  Expanded(
                    child: ListView.builder(
                      itemCount: systemSounds.length + _customSounds.length + 1,
                      itemBuilder: (context, index) {
                        // 1. Default Notification
                        if (index == 0) {
                          return ListTile(
                            leading: Radio<String>(
                              value: 'default',
                              groupValue: tempSelectedSound,
                              activeColor: colorScheme.primary,
                              onChanged: (val) async {
                                if (val != null) {
                                  setSheetState(() {
                                    tempSelectedSound = val;
                                  });
                                  await _safeInvokeMethod('stopRingtone');
                                }
                              },
                            ),
                            title: Text(
                              AppLocalizations.of(context).defaultNotification,
                            ),
                            onTap: () async {
                              setSheetState(() {
                                tempSelectedSound = 'default';
                              });
                              await _safeInvokeMethod('stopRingtone');
                            },
                          );
                        }

                        // 2. Custom Sounds
                        if (index <= _customSounds.length) {
                          final customSoundKey = _customSounds[index - 1];
                          final sound = AlarmSoundModel.fromKey(customSoundKey);
                          final path = sound.uri;
                          final name = sound.title;

                          return ListTile(
                            leading: Radio<String>(
                              value: customSoundKey,
                              groupValue: tempSelectedSound,
                              activeColor: colorScheme.primary,
                              onChanged: (val) async {
                                if (val != null) {
                                  setSheetState(() {
                                    tempSelectedSound = val;
                                  });
                                  final realPath = await _getRealIosPath(path, sound.fileName ?? name);
                                  await _safeInvokeMethod('playRingtone', {
                                    'uri': realPath,
                                  });
                                }
                              },
                            ),
                            title: Text(name),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                await _deleteCustomSound(customSoundKey);
                                setSheetState(() {
                                  if (tempSelectedSound == customSoundKey) {
                                    tempSelectedSound = 'default';
                                    _safeInvokeMethod('stopRingtone');
                                  }
                                });
                              },
                            ),
                            onTap: () async {
                              setSheetState(() {
                                tempSelectedSound = customSoundKey;
                              });
                              final realPath = await _getRealIosPath(path, sound.fileName ?? name);
                              await _safeInvokeMethod('playRingtone', {
                                'uri': realPath,
                              });
                            },
                          );
                        }

                        // 3. System Sounds
                        final soundIndex = index - _customSounds.length - 1;
                        final sound = systemSounds[soundIndex];
                        final soundModel = AlarmSoundModel(
                          type: AlarmSoundType.system,
                          uri: sound.uri,
                          title: sound.title,
                        );
                        final soundKey = soundModel.toKey();

                        return ListTile(
                          leading: Radio<String>(
                            value: soundKey,
                            groupValue: tempSelectedSound,
                            activeColor: colorScheme.primary,
                            onChanged: (val) async {
                              if (val != null) {
                                setSheetState(() {
                                  tempSelectedSound = val;
                                });
                                await _safeInvokeMethod('playRingtone', {
                                  'uri': sound.uri,
                                });
                              }
                            },
                          ),
                          title: Text(sound.title),
                          onTap: () async {
                            setSheetState(() {
                              tempSelectedSound = soundKey;
                            });
                            await _safeInvokeMethod('playRingtone', {
                              'uri': sound.uri,
                            });
                          },
                        );
                      },
                    ),
                  ),

                  // Confirm Button
                  Padding(
                    padding: EdgeInsets.all(AppW.w16),
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _alarmSound = tempSelectedSound;
                        });
                        await _saveSelectedSound(tempSelectedSound);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          48,
                        ), // Might want to keep this or use 48.h
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppR.r8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).confirmSelection,
                        style: TextStyle(fontSize: AppSp.sp16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() async {
      await _safeInvokeMethod('stopRingtone');
    });
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.taskToEdit == null ? l.addTaskTitle : l.editTaskTitle,
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppW.w16,
            vertical: AppH.h8,
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Task Name ────────────────────────────
                      Text(
                        l.taskNameLabel,
                        style: TextStyle(
                          fontSize: AppSp.sp16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: AppH.h8),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        focusNode: _nameFocus,
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: '${l.taskNameHint} ',
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return l.taskNameRequired;
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: AppH.h20),

                      // ── Task Description ─────────────────────
                      Text(
                        l.taskDescLabel,
                        style: TextStyle(
                          fontSize: AppSp.sp16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: AppH.h8),
                      TextFormField(
                        focusNode: _descFocus,
                        textInputAction: TextInputAction.done,
                        maxLines: 5,
                        controller: _descController,
                        decoration: InputDecoration(hintText: l.taskDescHint),
                      ),

                      SizedBox(height: AppH.h20),

                      // ── High Priority ────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l.highPriorityTasks,
                            style: TextStyle(
                              fontSize: AppSp.sp16,
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

                      SizedBox(height: AppH.h20),

                      // ── Reminder ─────────────────────────────
                      Text(
                        l.taskReminderLabel,
                        style: TextStyle(
                          fontSize: AppSp.sp16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: AppH.h12),
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
                          SizedBox(width: AppW.w12),
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

                      // Show chosen date and extra settings
                      if (_reminderEnabled && _reminderDate != null) ...[
                        SizedBox(height: AppH.h10),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppW.w16,
                            vertical: AppH.h10,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppR.r12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.alarm,
                                size: AppSp.sp18,
                                color: colorScheme.primary,
                              ),
                              SizedBox(width: AppW.w8),
                              Expanded(
                                child: Text(
                                  DateFormat(
                                    'dd MMM yyyy • hh:mm a',
                                  ).format(_reminderDate!),
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: AppSp.sp13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _clearReminder,
                                child: Icon(
                                  Icons.close,
                                  size: AppSp.sp18,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: AppH.h16),

                        // Alarm Settings
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.taskAlarmSound,
                                    style: TextStyle(fontSize: AppSp.sp12),
                                  ),
                                  SizedBox(height: AppH.h4),
                                  InkWell(
                                    onTap: _showRingtonePicker,
                                    borderRadius: BorderRadius.circular(
                                      AppR.r8,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppW.w12,
                                        vertical: AppH.h12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: colorScheme.outline,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppR.r8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              AlarmSoundModel.fromKey(_alarmSound).type == AlarmSoundType.defaultSound
                                                  ? l.defaultNotification
                                                  : AlarmSoundModel.fromKey(_alarmSound).title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(Icons.arrow_drop_down),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: AppW.w12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.taskSnoozeDuration,
                                    style: TextStyle(fontSize: AppSp.sp12),
                                  ),
                                  SizedBox(height: AppH.h4),
                                  DropdownButtonFormField<int>(
                                    value: _snoozeDuration,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: AppW.w12,
                                        vertical: AppH.h10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppR.r8,
                                        ),
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 5,
                                        child: Text('5 mins'),
                                      ),
                                      DropdownMenuItem(
                                        value: 10,
                                        child: Text('10 mins'),
                                      ),
                                      DropdownMenuItem(
                                        value: 15,
                                        child: Text('15 mins'),
                                      ),
                                      DropdownMenuItem(
                                        value: 30,
                                        child: Text('30 mins'),
                                      ),
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _snoozeDuration = v!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Save Button ──────────────────────────────────
              ElevatedButton.icon(
                onPressed: _submit,
                label: Text(
                  widget.taskToEdit == null
                      ? l.taskAddButton
                      : l.taskUpdateButton,
                  style: TextStyle(fontSize: AppSp.sp14),
                ),
                icon: Icon(widget.taskToEdit == null ? Icons.add : Icons.save),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(
                    AppW.w300 + AppW.w40,
                    AppH.h40,
                  ), // Or keep fixed if needed, used screenutil width instead
                ),
              ),
              SizedBox(height: AppH.h12),
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
          SnackBar(
            content: Text(AppLocalizations.of(context).taskReminderPast),
          ),
        );
        return;
      }
    }

    final task =
        widget.taskToEdit?.copyWith(
          taskName: _nameController.text.trim(),
          taskDescription: _descController.text.trim(),
          isHighPriority: _isHighPriority,
          reminderDate: _reminderEnabled ? _reminderDate : null,
          reminderEnabled: _reminderEnabled,
          alarmSound: _alarmSound,
          snoozeDuration: _snoozeDuration,
          dateTime: _reminderEnabled && _reminderDate != null
              ? _reminderDate!.toIso8601String()
              : DateTime.now().toIso8601String(),
        ) ??
        TaskModel(
          taskName: _nameController.text.trim(),
          taskDescription: _descController.text.trim(),
          isHighPriority: _isHighPriority,
          dateTime: _reminderEnabled && _reminderDate != null
              ? _reminderDate!.toIso8601String()
              : DateTime.now().toIso8601String(),
          reminderDate: _reminderEnabled ? _reminderDate : null,
          reminderEnabled: _reminderEnabled,
          alarmSound: _alarmSound,
          snoozeDuration: _snoozeDuration,
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
        padding: EdgeInsets.symmetric(vertical: AppH.h12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppR.r12),
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
              size: AppSp.sp18,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: AppW.w6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppSp.sp13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
