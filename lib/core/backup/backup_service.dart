import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/notifications/local_notification_service.dart';
import 'package:tasky/data/models/task_model.dart';
import 'package:tasky/data/models/user_model.dart';

import 'backup_model.dart';
import 'backup_validator.dart';

class BackupServiceException implements Exception {
  final String message;
  const BackupServiceException(this.message);
  @override
  String toString() => message;
}

class BackupService {
  // ── Export ──────────────────────────────────────────────────

  /// Reads all tasks from storage, builds a versioned BackupModel,
  /// writes it to a temp file, then opens the system share sheet.
  Future<void> exportAndShare() async {
    final tasks = await _readAllTasks();
    final user = await _readUser();
    final backup = BackupModel.create(tasks: tasks, user: user);
    final jsonString = backup.toJsonString();

    final tempDir = await getTemporaryDirectory();
    final dateStr = DateFormat('yyyy_MM_dd').format(DateTime.now());
    final file = File('${tempDir.path}/tasky_backup_$dateStr.json');
    await file.writeAsString(jsonString, encoding: utf8);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Tasky Backup – $dateStr',
    );

    // Save last manual backup timestamp
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'last_manual_backup_at', DateTime.now().toIso8601String());
  }

  // ── Import ──────────────────────────────────────────────────

  /// Opens a file picker, reads the JSON, validates it,
  /// and returns a [BackupPreview] without writing anything yet.
  Future<BackupPreview?> pickAndPreview() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;
    final pickedFile = result.files.first;
    final bytes = pickedFile.bytes;
    final path = pickedFile.path;

    String content;
    if (bytes != null) {
      content = utf8.decode(bytes);
    } else if (path != null) {
      content = await File(path).readAsString(encoding: utf8);
    } else {
      throw const BackupServiceException('Could not read the selected file.');
    }

    Map<String, dynamic> jsonData;
    try {
      jsonData = jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      throw const BackupServiceException('The selected file is not valid JSON.');
    }

    final validation = BackupValidator.validate(jsonData);
    if (!validation.isValid) {
      throw BackupServiceException(
          validation.message ?? 'Invalid backup file.');
    }

    final model = BackupModel.fromJson(jsonData);
    return BackupPreview(
      taskCount: model.tasks.length,
      createdAt: model.createdAt,
      version: model.version,
      model: model,
    );
  }

  /// Applies the restore using the selected [strategy].
  /// - [replace]: clears current tasks, saves imported ones.
  /// - [merge]: keeps existing tasks, adds new (skips duplicate IDs).
  Future<void> applyRestore(
      BackupPreview preview, RestoreStrategy strategy) async {
    final prefs = await SharedPreferences.getInstance();
    final importedTasks = preview.model.tasks;

    List<TaskModel> finalTasks;

    switch (strategy) {
      case RestoreStrategy.replace:
        final existing = await _readAllTasks();
        for (final t in existing) {
          if (t.reminderEnabled) {
            await LocalNotificationService.instance.cancel(t.id);
          }
        }
        finalTasks = importedTasks;
        break;

      case RestoreStrategy.merge:
        final existing = await _readAllTasks();
        final existingIds = existing.map((t) => t.id).toSet();
        final newOnly =
            importedTasks.where((t) => !existingIds.contains(t.id)).toList();
        finalTasks = [...existing, ...newOnly];
        break;
    }

    await prefs.setStringList(
      'tasks',
      finalTasks.map((t) => jsonEncode(t.toJson())).toList(),
    );

    // Restore user profile if present in backup
    if (preview.model.user != null) {
      await prefs.setString('user', jsonEncode(preview.model.user!.toJson()));
    }

    // Reschedule reminders for restored tasks
    for (final task in finalTasks) {
      if (task.reminderEnabled &&
          task.reminderDate != null &&
          task.reminderDate!.isAfter(DateTime.now())) {
        await LocalNotificationService.instance.schedule(task);
      }
    }
  }

  // ── Silent Auto Backup ──────────────────────────────────────

  /// Writes a silent backup to the visible external storage under
  /// `Android/data/com.bsh.tasky/files/TaskyBackups/`.
  ///
  /// Keeps at most [maxCopies] files — oldest is deleted when the limit
  /// is exceeded.
  Future<String> writeSilentBackup({int maxCopies = 3}) async {
    final tasks = await _readAllTasks();
    final user = await _readUser();
    final backup = BackupModel.create(tasks: tasks, user: user);
    final jsonString = backup.toJsonString();

    // ── Resolve destination folder ────────────────────────────
    final extDir = await getExternalStorageDirectory(); // Android/data/<pkg>/files
    if (extDir == null) {
      throw const BackupServiceException(
          'External storage is unavailable on this device.');
    }
    final backupDir = Directory('${extDir.path}/TaskyBackups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    // ── Rotate: keep only (maxCopies - 1) existing files ─────
    final existing = backupDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

    while (existing.length >= maxCopies) {
      final oldest = existing.removeAt(0);
      await oldest.delete();
      debugPrint('🗑️ [Backup] Deleted old backup: ${oldest.path}');
    }

    // ── Write new file ────────────────────────────────────────
    final stamp = DateFormat('yyyy_MM_dd_HH_mm').format(DateTime.now());
    final file = File('${backupDir.path}/tasky_backup_$stamp.json');
    await file.writeAsString(jsonString, encoding: utf8);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'last_auto_backup_at', DateTime.now().toIso8601String());

    debugPrint('📦 [Backup] Auto backup saved to: ${file.path}');
    return file.path;
  }

  // ── Helpers ─────────────────────────────────────────────────

  Future<List<TaskModel>> _readAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];
    return tasksJson
        .map((j) => TaskModel.fromJson(jsonDecode(j) as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel?> _readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user');
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
