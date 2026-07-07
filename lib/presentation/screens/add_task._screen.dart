import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:engez/data/models/task_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_system_ringtones/flutter_system_ringtones.dart';
import 'package:engez/core/theme/app_sizes.dart';
import 'package:engez/presentation/widgets/mic_permission_dialog.dart';
import 'package:engez/core/voice/voice_input_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:engez/core/voice/reminder_date_parser.dart';
import 'package:engez/l10n/app_localizations.dart';
import 'package:engez/presentation/widgets/mic_button.dart';

enum VoiceField { title, description }

class AddTaskScreen extends StatefulWidget {
  final TaskModel? taskToEdit;
  const AddTaskScreen({super.key, this.taskToEdit});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  static const _pickerChannel = MethodChannel('app.fikrasoft.engez/ringtone_picker');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  // ── Existing state ───────────────────────────────────────────
  bool _isHighPriority = false;
  bool _reminderEnabled = false;
  DateTime? _reminderDate;
  String _alarmSound = 'default';
  int _snoozeDuration = 10;
  List<String> _customSounds = [];

  // ── Voice state ──────────────────────────────────────────────
  final VoiceInputController _voice = VoiceInputController(localeId: 'ar-EG');
  bool _isListening = false;
  bool _isPushToTalk = false;
  VoiceField? _activeVoiceField;
  ParsedReminder? _detectedReminder;

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

  @override
  void dispose() {
    _nameFocus.dispose();
    _descFocus.dispose();
    _nameController.dispose();
    _descController.dispose();
    _voice.dispose();
    super.dispose();
  }

  // ── Sound helpers ────────────────────────────────────────────
  Future<void> _loadCustomSounds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _customSounds = prefs.getStringList('custom_user_sounds') ?? []; });
  }

  Future<void> _saveCustomSound(String uri, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final item = '$uri|$name';
    if (!_customSounds.contains(item)) {
      _customSounds.add(item);
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
      final last = prefs.getString('last_selected_alarm_sound');
      if (last != null) setState(() => _alarmSound = last);
    }
  }

  Future<void> _saveSelectedSound(String soundData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_selected_alarm_sound', soundData);
  }

  // ── Voice input ──────────────────────────────────────────────

  void _onVoiceResult(String words, {required bool isFinal}) {
    final controller = _activeVoiceField == VoiceField.description ? _descController : _nameController;
    setState(() { controller.text = words; });
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: words.length),
    );
    if (isFinal && words.isNotEmpty && _activeVoiceField == VoiceField.title) {
      final parsed = ReminderDateParser.parse(words);
      if (parsed.hasReminder) {
        setState(() {
          _detectedReminder = parsed;
          _reminderDate = parsed.dateTime;
          _reminderEnabled = true;
        });
      }
    }
    if (isFinal) {
      setState(() { _isListening = false; _isPushToTalk = false; _activeVoiceField = null; });
    }
  }

  void _onVoiceStateChanged(VoiceInputState state) {
    setState(() => _isListening = state == VoiceInputState.listening);
  }

  void _onVoiceError(String msg, {bool isPermissionPermanentlyDenied = false}) async {
    final wasPushToTalk = _isPushToTalk;
    final wasField = _activeVoiceField;
    setState(() { _isListening = false; _isPushToTalk = false; });
    if (!mounted) return;

    if (isPermissionPermanentlyDenied && wasField != null) {
      final granted = await showDialog<bool>(
        context: context,
        builder: (_) => const MicPermissionDialog(),
      );
      if (granted == true && mounted) {
        _startVoice(wasField, pushToTalk: wasPushToTalk);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  Future<void> _startVoice(VoiceField field, {bool pushToTalk = false}) async {
    if (_isListening) return;
    setState(() { 
      _isPushToTalk = pushToTalk; 
      _activeVoiceField = field;
      _detectedReminder = null; 
    });
    await _voice.startListening(
      onResult: _onVoiceResult,
      onStateChanged: _onVoiceStateChanged,
      onError: _onVoiceError,
      pushToTalk: pushToTalk,
    );
  }

  Future<void> _stopVoice() async {
    if (!_isListening) return;
    await _voice.stopListening();
    setState(() { _isListening = false; _isPushToTalk = false; _activeVoiceField = null; });
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
    setState(() {
      _reminderDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _reminderEnabled = true;
      _detectedReminder = null;
    });
  }

  void _clearReminder() {
    setState(() { _reminderEnabled = false; _reminderDate = null; _detectedReminder = null; });
  }

  // ── Ringtone picker ──────────────────────────────────────────
  Future<void> _showRingtonePicker() async {
    showDialog(context: context, barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()));
    List<Ringtone> systemSounds = [];
    try {
      final ringtones = await FlutterSystemRingtones.getRingtoneSounds();
      final alarms = await FlutterSystemRingtones.getAlarmSounds();
      final seen = <String>{};
      systemSounds = [...ringtones, ...alarms].where((s) => seen.add(s.uri)).toList();
    } catch (_) {}
    if (mounted) Navigator.pop(context);
    if (!mounted) return;
    String tempSelectedSound = _alarmSound;
    await showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppR.r16))),
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return StatefulBuilder(builder: (context, setSheetState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(children: [
              Padding(
                padding: EdgeInsets.all(AppW.w16),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(AppLocalizations.of(context).taskAlarmSound,
                    style: TextStyle(fontSize: AppSp.sp18, fontWeight: FontWeight.bold, color: cs.onSurface)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ]),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(padding: EdgeInsets.all(AppW.w8),
                  decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.add, color: cs.primary)),
                title: Text(AppLocalizations.of(context).addCustomSound,
                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                onTap: () async {
                  try {
                    final result = await FilePicker.pickFiles(type: FileType.audio);
                    if (result != null && result.files.single.path != null) {
                      final path = result.files.single.path!;
                      final name = result.files.single.name;
                      String finalPath = path;
                      if (Theme.of(context).platform == TargetPlatform.android) {
                        final String? systemUri = await _pickerChannel.invokeMethod('saveAudioToSystem', {'path': path, 'title': name.split('.').first});
                        if (systemUri != null) finalPath = systemUri;
                      }
                      final soundKey = '$finalPath|$name';
                      await _saveCustomSound(finalPath, name);
                      setSheetState(() => tempSelectedSound = soundKey);
                      await _pickerChannel.invokeMethod('playRingtone', {'uri': finalPath});
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${AppLocalizations.of(context).errorPickingFile}: $e')));
                  }
                },
              ),
              const Divider(height: 1),
              Expanded(child: ListView.builder(
                itemCount: systemSounds.length + _customSounds.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      leading: Radio<String>(value: 'default', groupValue: tempSelectedSound,
                        activeColor: cs.primary,
                        onChanged: (val) async { if (val != null) { setSheetState(() => tempSelectedSound = val); await _pickerChannel.invokeMethod('stopRingtone'); } }),
                      title: Text(AppLocalizations.of(context).defaultNotification),
                      onTap: () async { setSheetState(() => tempSelectedSound = 'default'); await _pickerChannel.invokeMethod('stopRingtone'); },
                    );
                  }
                  if (index <= _customSounds.length) {
                    final customSound = _customSounds[index - 1];
                    final parts = customSound.split('|');
                    final path = parts[0]; final name = parts[1];
                    return ListTile(
                      leading: Radio<String>(value: customSound, groupValue: tempSelectedSound, activeColor: cs.primary,
                        onChanged: (val) async { if (val != null) { setSheetState(() => tempSelectedSound = val); await _pickerChannel.invokeMethod('playRingtone', {'uri': path}); } }),
                      title: Text(name),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async { await _deleteCustomSound(customSound); setSheetState(() { if (tempSelectedSound == customSound) { tempSelectedSound = 'default'; _pickerChannel.invokeMethod('stopRingtone'); } }); }),
                      onTap: () async { setSheetState(() => tempSelectedSound = customSound); await _pickerChannel.invokeMethod('playRingtone', {'uri': path}); },
                    );
                  }
                  final soundIndex = index - _customSounds.length - 1;
                  final sound = systemSounds[soundIndex];
                  final soundKey = '${sound.uri}|${sound.title}';
                  return ListTile(
                    leading: Radio<String>(value: soundKey, groupValue: tempSelectedSound, activeColor: cs.primary,
                      onChanged: (val) async { if (val != null) { setSheetState(() => tempSelectedSound = val); await _pickerChannel.invokeMethod('playRingtone', {'uri': sound.uri}); } }),
                    title: Text(sound.title),
                    onTap: () async { setSheetState(() => tempSelectedSound = soundKey); await _pickerChannel.invokeMethod('playRingtone', {'uri': sound.uri}); },
                  );
                },
              )),
              Padding(padding: EdgeInsets.all(AppW.w16),
                child: ElevatedButton(
                  onPressed: () async { setState(() => _alarmSound = tempSelectedSound); await _saveSelectedSound(tempSelectedSound); Navigator.pop(context); },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppR.r8))),
                  child: Text(AppLocalizations.of(context).confirmSelection, style: TextStyle(fontSize: AppSp.sp16)),
                )),
            ]),
          );
        });
      },
    ).whenComplete(() async { await _pickerChannel.invokeMethod('stopRingtone'); });
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.taskToEdit == null ? l.addTaskTitle : l.editTaskTitle)),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppW.w16, vertical: AppH.h8),
          child: Column(children: [
            Expanded(child: SingleChildScrollView(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Task Name ─────────────────────────────────
                Text(l.taskNameLabel, style: TextStyle(fontSize: AppSp.sp16, fontWeight: FontWeight.w400)),
                SizedBox(height: AppH.h8),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  focusNode: _nameFocus,
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '${l.taskNameHint} ',
                    suffixIcon: MicButton(
                      isListening: _isListening && _activeVoiceField == VoiceField.title,
                      semanticLabel: 'Voice input for task title',
                      onTap: () => (_isListening && _activeVoiceField == VoiceField.title) ? _stopVoice() : _startVoice(VoiceField.title),
                      onLongPressStart: () => _startVoice(VoiceField.title, pushToTalk: true),
                      onLongPressEnd: () { if (_isPushToTalk && _activeVoiceField == VoiceField.title) _stopVoice(); },
                    ),
                  ),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? l.taskNameRequired : null,
                ),

                // ── Listening indicator ───────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: (_isListening && _activeVoiceField == VoiceField.title)
                      ? Padding(
                          key: const ValueKey('listening_title'),
                          padding: EdgeInsets.only(top: AppH.h6),
                          child: Row(children: [
                            SizedBox(width: AppW.w4),
                            Icon(Icons.graphic_eq, size: AppSp.sp14, color: cs.error),
                            SizedBox(width: AppW.w4),
                            Text(
                              _isPushToTalk ? 'اضغط إيقاف عند الانتهاء…' : 'جاري الاستماع…',
                              style: TextStyle(fontSize: AppSp.sp12, color: cs.error, fontWeight: FontWeight.w500),
                            ),
                          ]),
                        )
                      : const SizedBox.shrink(key: ValueKey('idle')),
                ),

                // ── Detected reminder card ────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _detectedReminder != null && _detectedReminder!.hasReminder
                      ? _ReminderDetectedCard(
                          key: const ValueKey('detected'),
                          description: _detectedReminder!.description!,
                          onDismiss: () => setState(() => _detectedReminder = null),
                        )
                      : const SizedBox.shrink(key: ValueKey('no-detected')),
                ),

                SizedBox(height: AppH.h20),

                // ── Task Description ──────────────────────────
                Text(l.taskDescLabel, style: TextStyle(fontSize: AppSp.sp16, fontWeight: FontWeight.w400)),
                SizedBox(height: AppH.h8),
                TextFormField(
                  focusNode: _descFocus,
                  textInputAction: TextInputAction.done,
                  maxLines: 5,
                  minLines: 3,
                  controller: _descController,
                  decoration: InputDecoration(
                    hintText: l.taskDescHint,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MicButton(
                            isListening: _isListening && _activeVoiceField == VoiceField.description,
                            semanticLabel: 'Voice input for task description',
                            onTap: () => (_isListening && _activeVoiceField == VoiceField.description) ? _stopVoice() : _startVoice(VoiceField.description),
                            onLongPressStart: () => _startVoice(VoiceField.description, pushToTalk: true),
                            onLongPressEnd: () { if (_isPushToTalk && _activeVoiceField == VoiceField.description) _stopVoice(); },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // ── Listening indicator ───────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: (_isListening && _activeVoiceField == VoiceField.description)
                      ? Padding(
                          key: const ValueKey('listening_desc'),
                          padding: EdgeInsets.only(top: AppH.h6),
                          child: Row(children: [
                            SizedBox(width: AppW.w4),
                            Icon(Icons.graphic_eq, size: AppSp.sp14, color: cs.error),
                            SizedBox(width: AppW.w4),
                            Text(
                              _isPushToTalk ? 'اضغط إيقاف عند الانتهاء…' : 'جاري الاستماع…',
                              style: TextStyle(fontSize: AppSp.sp12, color: cs.error, fontWeight: FontWeight.w500),
                            ),
                          ]),
                        )
                      : const SizedBox.shrink(key: ValueKey('idle')),
                ),

                SizedBox(height: AppH.h20),

                // ── High Priority ─────────────────────────────
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(l.highPriorityTasks, style: TextStyle(fontSize: AppSp.sp16, fontWeight: FontWeight.w400)),
                  Switch(value: _isHighPriority, onChanged: (v) => setState(() => _isHighPriority = v)),
                ]),

                SizedBox(height: AppH.h20),

                // ── Reminder ──────────────────────────────────
                Text(l.taskReminderLabel, style: TextStyle(fontSize: AppSp.sp16, fontWeight: FontWeight.w400)),
                SizedBox(height: AppH.h12),
                Row(children: [
                  Expanded(child: _ReminderOption(label: 'None', isSelected: !_reminderEnabled, onTap: _clearReminder)),
                  SizedBox(width: AppW.w12),
                  Expanded(child: _ReminderOption(label: 'Pick Date & Time', isSelected: _reminderEnabled, onTap: _pickReminder)),
                ]),

                if (_reminderEnabled && _reminderDate != null) ...[
                  SizedBox(height: AppH.h10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppW.w16, vertical: AppH.h10),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppR.r12),
                    ),
                    child: Row(children: [
                      Icon(Icons.alarm, size: AppSp.sp18, color: cs.primary),
                      SizedBox(width: AppW.w8),
                      Expanded(child: Text(
                        DateFormat('dd MMM yyyy • hh:mm a').format(_reminderDate!),
                        style: TextStyle(color: cs.primary, fontSize: AppSp.sp13, fontWeight: FontWeight.w500),
                      )),
                      GestureDetector(onTap: _clearReminder,
                        child: Icon(Icons.close, size: AppSp.sp18, color: cs.primary)),
                    ]),
                  ),

                  SizedBox(height: AppH.h16),

                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.taskAlarmSound, style: TextStyle(fontSize: AppSp.sp12)),
                      SizedBox(height: AppH.h4),
                      InkWell(
                        onTap: _showRingtonePicker,
                        borderRadius: BorderRadius.circular(AppR.r8),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: AppW.w12, vertical: AppH.h12),
                          decoration: BoxDecoration(
                            border: Border.all(color: cs.outline),
                            borderRadius: BorderRadius.circular(AppR.r8),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Expanded(child: Text(
                              _alarmSound.contains('|') ? _alarmSound.split('|')[1] : l.defaultNotification,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            )),
                            const Icon(Icons.arrow_drop_down),
                          ]),
                        ),
                      ),
                    ])),
                    SizedBox(width: AppW.w12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.taskSnoozeDuration, style: TextStyle(fontSize: AppSp.sp12)),
                      SizedBox(height: AppH.h4),
                      DropdownButtonFormField<int>(
                        value: _snoozeDuration,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: AppW.w12, vertical: AppH.h10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppR.r8)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 5, child: Text('5 mins')),
                          DropdownMenuItem(value: 10, child: Text('10 mins')),
                          DropdownMenuItem(value: 15, child: Text('15 mins')),
                          DropdownMenuItem(value: 30, child: Text('30 mins')),
                        ],
                        onChanged: (v) => setState(() => _snoozeDuration = v!),
                      ),
                    ])),
                  ]),
                ],
              ],
            ))),

            // ── Save Button ────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _isListening ? null : _submit,
              label: Text(
                widget.taskToEdit == null ? l.taskAddButton : l.taskUpdateButton,
                style: TextStyle(fontSize: AppSp.sp14),
              ),
              icon: Icon(widget.taskToEdit == null ? Icons.add : Icons.save),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(AppW.w300 + AppW.w40, AppH.h40),
              ),
            ),
            SizedBox(height: AppH.h12),
          ]),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_reminderEnabled && _reminderDate != null) {
      if (_reminderDate!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).taskReminderPast)));
        return;
      }
    }
    final task = widget.taskToEdit?.copyWith(
          taskName: _nameController.text.trim(),
          taskDescription: _descController.text.trim(),
          isHighPriority: _isHighPriority,
          reminderDate: _reminderEnabled ? _reminderDate : null,
          reminderEnabled: _reminderEnabled,
          alarmSound: _alarmSound,
          snoozeDuration: _snoozeDuration,
        ) ??
        TaskModel(
          taskName: _nameController.text.trim(),
          taskDescription: _descController.text.trim(),
          isHighPriority: _isHighPriority,
          dateTime: DateTime.now().toIso8601String(),
          reminderDate: _reminderEnabled ? _reminderDate : null,
          reminderEnabled: _reminderEnabled,
          alarmSound: _alarmSound,
          snoozeDuration: _snoozeDuration,
        );
    if (mounted) Navigator.pop(context, task);
  }
}

// ── Reminder detected info card ───────────────────────────────────
class _ReminderDetectedCard extends StatelessWidget {
  final String description;
  final VoidCallback onDismiss;
  const _ReminderDetectedCard({super.key, required this.description, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: AppH.h8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppW.w12, vertical: AppH.h8),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppR.r10),
          border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          Text('✨', style: TextStyle(fontSize: AppSp.sp14)),
          SizedBox(width: AppW.w8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('تم اكتشاف تذكير',
              style: TextStyle(fontSize: AppSp.sp12, fontWeight: FontWeight.w700, color: cs.onPrimaryContainer)),
            Text(description,
              style: TextStyle(fontSize: AppSp.sp12, color: cs.onPrimaryContainer)),
          ])),
          GestureDetector(onTap: onDismiss,
            child: Icon(Icons.close, size: AppSp.sp16, color: cs.onPrimaryContainer)),
        ]),
      ),
    );
  }
}

// ── Reminder option chip ──────────────────────────────────────────
class _ReminderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ReminderOption({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: AppH.h12),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withValues(alpha: 0.12) : cs.surface,
          borderRadius: BorderRadius.circular(AppR.r12),
          border: Border.all(color: isSelected ? cs.primary : cs.outline, width: isSelected ? 1.5 : 1),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: AppSp.sp18, color: isSelected ? cs.primary : cs.onSurfaceVariant),
          SizedBox(width: AppW.w6),
          Flexible(child: Text(label, style: TextStyle(
            fontSize: AppSp.sp13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? cs.primary : cs.onSurfaceVariant,
          ))),
        ]),
      ),
    );
  }
}
