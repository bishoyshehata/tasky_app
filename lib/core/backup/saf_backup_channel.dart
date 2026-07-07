import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Flutter-side wrapper for the `com.bsh.tasky/saf_backup` MethodChannel.
///
/// Handles all communication with the native Android SAF implementation.
/// On non-Android platforms, falls back to no-op / throws [UnsupportedError].
class SafBackupChannel {
  static const _channel = MethodChannel('com.bsh.tasky/saf_backup');
  static const _keyTreeUri = 'saf_tree_uri';

  // ── Folder management ────────────────────────────────────────

  /// Returns the persisted tree URI string, or null if not yet chosen.
  static Future<String?> getSavedFolderUri() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTreeUri);
  }

  /// Returns true if the user has already picked a folder.
  static Future<bool> hasSavedFolder() async =>
      (await getSavedFolderUri()) != null;

  /// Clears the saved folder URI (used when user wants to re-pick).
  static Future<void> clearSavedFolder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTreeUri);
  }

  /// Opens the native folder picker (ACTION_OPEN_DOCUMENT_TREE).
  ///
  /// Returns the tree URI string on success, or null if the user cancelled.
  /// The native side calls `takePersistableUriPermission` automatically.
  static Future<String?> openFolderPicker() async {
    if (!defaultTargetPlatform.isAndroid) return null;
    try {
      final uri = await _channel.invokeMethod<String>('openFolderPicker');
      if (uri != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyTreeUri, uri);
      }
      return uri;
    } on PlatformException catch (e) {
      debugPrint('SAF openFolderPicker error: $e');
      return null;
    }
  }

  // ── Backup write ─────────────────────────────────────────────

  /// Writes a silent backup to the SAF tree folder.
  ///
  /// [maxCopies] — older files are deleted once this limit is reached.
  ///
  /// Returns the created file's document URI string.
  ///
  /// Throws a [SafBackupException] if:
  /// - No folder has been chosen yet ([NoFolderChosenException])
  /// - The native write fails
  static Future<String> writeSilentBackup({
    required String jsonContent,
    int maxCopies = 3,
  }) async {
    final treeUri = await getSavedFolderUri();
    if (treeUri == null) throw const NoFolderChosenException();

    final stamp = DateFormat('yyyy_MM_dd_HH_mm').format(DateTime.now());
    final fileName = 'engez_backup_$stamp';

    try {
      final fileUri = await _channel.invokeMethod<String>(
        'writeBackupToTree',
        {
          'treeUriStr': treeUri,
          'fileName': fileName,
          'content': jsonContent,
          'maxCopies': maxCopies,
        },
      );
      return fileUri ?? '';
    } on PlatformException catch (e) {
      throw SafBackupException(e.message ?? 'Unknown write error');
    }
  }

  // ── File listing ─────────────────────────────────────────────

  /// Lists backup file names in the chosen folder (newest first).
  /// Returns an empty list if no folder is set or on error.
  static Future<List<String>> listBackupFiles() async {
    final treeUri = await getSavedFolderUri();
    if (treeUri == null) return [];
    try {
      final raw = await _channel.invokeMethod<List<Object?>>('listBackupFiles', {
        'treeUriStr': treeUri,
      });
      return raw?.cast<String>() ?? [];
    } on PlatformException {
      return [];
    }
  }
}

// ── Exceptions ───────────────────────────────────────────────────

class SafBackupException implements Exception {
  final String message;
  const SafBackupException(this.message);
  @override
  String toString() => message;
}

class NoFolderChosenException extends SafBackupException {
  const NoFolderChosenException()
      : super('No backup folder chosen. Please pick a folder first.');
}

// ── Platform extension helper ────────────────────────────────────

extension on TargetPlatform {
  bool get isAndroid => this == TargetPlatform.android;
}
