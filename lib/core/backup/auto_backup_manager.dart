import 'package:shared_preferences/shared_preferences.dart';

import 'backup_service.dart';

/// Manages auto-backup configuration and triggers.
/// Settings stored in SharedPreferences:
///   auto_backup_enabled (bool)
///   auto_backup_frequency_days (int: 1 | 2 | 5 | 7)
///   last_auto_backup_at (ISO string)
class AutoBackupManager {
  static const _keyEnabled = 'auto_backup_enabled';
  static const _keyFrequency = 'auto_backup_frequency_days';
  static const _keyLastAt = 'last_auto_backup_at';

  /// frequency == 0 → test mode: every 1 minute
  /// frequency > 0  → every N days
  static const List<int> frequencyOptions = [0, 1, 2, 5, 7];

  // ── Settings getters/setters ──────────────────────────────

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, value);
  }

  static Future<int> getFrequencyDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyFrequency) ?? 1;
  }

  static Future<void> setFrequencyDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFrequency, days);
  }

  static Future<DateTime?> getLastBackupAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLastAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static Future<DateTime?> getLastManualBackupAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('last_manual_backup_at');
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static Future<String?> getLastBackupPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_auto_backup_path');
  }

  // ── Check and run ─────────────────────────────────────────

  /// Call this on app start and after task changes.
  /// Performs a silent backup if auto-backup is enabled and the interval has elapsed.
  static Future<void> checkAndRun() async {
    final enabled = await isEnabled();
    if (!enabled) return;

    final frequency = await getFrequencyDays();
    final lastBackup = await getLastBackupAt();

    final now = DateTime.now();
    if (lastBackup != null) {
      if (frequency == 0) {
        // Test mode: trigger every 1 minute
        if (now.difference(lastBackup).inMinutes < 1) return;
      } else {
        if (now.difference(lastBackup).inDays < frequency) return;
      }
    }

    try {
      await BackupService().writeSilentBackup();
    } catch (e) {
      // Silent failure — don't interrupt the user
    }
  }
}
