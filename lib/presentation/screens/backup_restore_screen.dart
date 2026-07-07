import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:engez/core/backup/auto_backup_manager.dart';
import 'package:engez/core/backup/backup_model.dart';
import 'package:engez/core/backup/backup_service.dart';
import 'package:engez/core/backup/saf_backup_channel.dart';
import 'package:engez/domain/usecases/create_backup_use_case.dart';
import 'package:engez/domain/usecases/restore_backup_use_case.dart';
import 'package:engez/l10n/app_localizations.dart';
import 'package:engez/presentation/screens/main_navigation_screen.dart';
import 'package:engez/core/theme/app_sizes.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final _backupService = BackupService();
  late final _createUseCase = CreateBackupUseCase(_backupService);
  late final _restoreUseCase = RestoreBackupUseCase(_backupService);

  bool _isExporting = false;
  bool _isImporting = false;
  bool _isRunningAutoBackup = false;
  bool _isPickingFolder = false;
  bool _autoEnabled = false;
  int _autoFrequency = 1;
  DateTime? _lastManualBackup;
  DateTime? _lastAutoBackup;
  String? _lastAutoBackupPath;

  // SAF state — only relevant on Android
  String? _savedFolderUri;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await AutoBackupManager.isEnabled();
    final freq = await AutoBackupManager.getFrequencyDays();
    final lastManual = await AutoBackupManager.getLastManualBackupAt();
    final lastAuto = await AutoBackupManager.getLastBackupAt();
    final lastPath = await AutoBackupManager.getLastBackupPath();
    final folderUri = Platform.isAndroid
        ? await SafBackupChannel.getSavedFolderUri()
        : null;

    if (mounted) {
      setState(() {
        _autoEnabled = enabled;
        _autoFrequency = freq;
        _lastManualBackup = lastManual;
        _lastAutoBackup = lastAuto;
        _lastAutoBackupPath = lastPath;
        _savedFolderUri = folderUri;
      });
    }
  }

  // ── Export ──────────────────────────────────────────────────

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    try {
      await _createUseCase.execute();
      if (mounted) {
        _loadSettings();
        _showSnack(
          AppLocalizations.of(context).backupSuccessful,
          isError: false,
        );
      }
    } catch (e) {
      if (mounted)
        _showSnack(
          '${AppLocalizations.of(context).backupFailed}: $e',
          isError: true,
        );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // ── Import ──────────────────────────────────────────────────

  Future<void> _handleImport() async {
    setState(() => _isImporting = true);
    BackupPreview? preview;
    try {
      preview = await _restoreUseCase.preview();
    } catch (e) {
      if (mounted) _showSnack('$e', isError: true);
      setState(() => _isImporting = false);
      return;
    } finally {
      if (mounted && preview == null) setState(() => _isImporting = false);
    }

    if (preview == null || !mounted) {
      setState(() => _isImporting = false);
      return;
    }

    setState(() => _isImporting = false);
    await _showRestorePreviewSheet(preview);
  }

  Future<void> _showRestorePreviewSheet(BackupPreview preview) async {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr = DateFormat(
      'dd MMM yyyy',
    ).format(preview.createdAt.toLocal());
    final timeStr = DateFormat('hh:mm a').format(preview.createdAt.toLocal());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppR.r24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(AppW.w24, AppH.h8, AppW.w24, AppH.h40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: AppW.w40,
                height: AppH.h4,
                margin: EdgeInsets.only(bottom: AppH.h20, top: AppH.h8),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(AppR.r4),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppW.w10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppR.r12),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(width: AppW.w12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.restoreDialogTitle,
                      style: TextStyle(
                        fontSize: AppSp.sp18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Version ${preview.version}',
                      style: TextStyle(
                        fontSize: AppSp.sp12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppH.h20),
            Container(
              padding: EdgeInsets.all(AppW.w16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppR.r16),
              ),
              child: Row(
                children: [
                  _statChip(
                    colorScheme,
                    Icons.task_alt,
                    '${preview.taskCount}',
                    'Tasks',
                  ),
                  SizedBox(width: AppW.w16),
                  _statChip(
                    colorScheme,
                    Icons.calendar_today_outlined,
                    dateStr,
                    timeStr,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppH.h24),
            _strategyButton(
              ctx: ctx,
              icon: Icons.merge_outlined,
              label: l.backupMerge,
              subtitle: l.backupMergeDesc,
              color: colorScheme.primary,
              onTap: () => _applyRestore(ctx, preview, RestoreStrategy.merge),
            ),
            SizedBox(height: AppH.h10),
            _strategyButton(
              ctx: ctx,
              icon: Icons.swap_horiz_rounded,
              label: l.backupReplace,
              subtitle: l.backupReplaceDesc,
              color: colorScheme.error,
              onTap: () => _confirmReplace(ctx, preview, l),
            ),
            SizedBox(height: AppH.h10),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                l.cancel,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(ColorScheme cs, IconData icon, String main, String sub) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: AppSp.sp18, color: cs.primary),
          SizedBox(width: AppW.w8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                main,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppSp.sp15,
                  color: cs.onSurface,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  fontSize: AppSp.sp11,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _strategyButton({
    required BuildContext ctx,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(ctx).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppR.r16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppW.w16, vertical: AppH.h14),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(AppR.r16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: AppSp.sp24),
            SizedBox(width: AppW.w12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      fontSize: AppSp.sp14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: AppSp.sp12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: AppSp.sp20),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReplace(
    BuildContext sheetCtx,
    BackupPreview preview,
    AppLocalizations l,
  ) async {
    Navigator.pop(sheetCtx);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.backupReplaceConfirmTitle),
        content: Text(l.backupReplaceConfirmDesc(preview.taskCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l.backupReplaceBtn,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _applyRestore(context, preview, RestoreStrategy.replace);
    }
  }

  Future<void> _applyRestore(
    BuildContext ctx,
    BackupPreview preview,
    RestoreStrategy strategy,
  ) async {
    if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();

    try {
      await _restoreUseCase.apply(preview, strategy);
      MainNavigationScreen.refreshTrigger.value =
          !MainNavigationScreen.refreshTrigger.value;
      if (mounted) {
        _showSnack(
          strategy == RestoreStrategy.replace
              ? AppLocalizations.of(context).backupTasksReplaced
              : AppLocalizations.of(context).backupTasksMerged,
          isError: false,
        );
      }
    } catch (e) {
      if (mounted)
        _showSnack(
          '${AppLocalizations.of(context).restoreFailed}: $e',
          isError: true,
        );
    }
  }

  // ── Auto Backup ─────────────────────────────────────────────

  Future<void> _onToggleAuto(bool value) async {
    await AutoBackupManager.setEnabled(value);
    setState(() => _autoEnabled = value);
    if (value && _savedFolderUri != null) {
      await _runAutoBackupNow(silent: true);
    }
  }

  /// Opens the SAF folder picker. On success, stores the URI and optionally
  /// runs a first backup immediately.
  Future<void> _pickFolder({bool runBackupAfter = false}) async {
    setState(() => _isPickingFolder = true);
    try {
      final uri = await SafBackupChannel.openFolderPicker();
      if (uri != null && mounted) {
        setState(() => _savedFolderUri = uri);
        if (runBackupAfter) {
          await _runAutoBackupNow(silent: true);
        } else {
          _showSnack(
            AppLocalizations.of(context).backupSuccessful,
            isError: false,
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isPickingFolder = false);
    }
  }

  Future<void> _runAutoBackupNow({bool silent = false}) async {
    // On Android: if no folder is chosen yet, open picker first.
    if (Platform.isAndroid && _savedFolderUri == null) {
      await _pickFolder(runBackupAfter: true);
      return;
    }

    setState(() => _isRunningAutoBackup = true);
    try {
      await BackupService().writeSilentBackup();
      await _loadSettings();
      if (mounted && !silent) {
        _showSnack(
          AppLocalizations.of(context).backupSuccessful,
          isError: false,
        );
      }
    } on NoFolderChosenException {
      // The folder URI was cleared externally; ask again
      if (mounted) {
        setState(() => _savedFolderUri = null);
        await _pickFolder(runBackupAfter: true);
      }
    } catch (e) {
      if (mounted)
        _showSnack(
          '${AppLocalizations.of(context).backupFailed}: $e',
          isError: true,
        );
    } finally {
      if (mounted) setState(() => _isRunningAutoBackup = false);
    }
  }

  Future<void> _onFrequencyChanged(int days) async {
    await AutoBackupManager.setFrequencyDays(days);
    setState(() => _autoFrequency = days);
  }

  String _frequencyLabel(int days, AppLocalizations l) {
    return switch (days) {
      1 => l.backupFreqDay,
      _ => l.backupFreqDays(days),
    };
  }

  // ── SAF: display a short human-readable folder name ──────────

  /// Extracts a display name from a SAF tree URI.
  /// e.g. "content://...primary%3ADownloads%2FEngezBackups" → "Downloads/EngezBackups"
  String _folderDisplayName(String uri) {
    try {
      final decoded = Uri.decodeComponent(uri);
      final match = RegExp(r'primary:(.+)$').firstMatch(decoded);
      return match?.group(1) ?? uri;
    } catch (_) {
      return uri;
    }
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.backupRestoreTitle),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppW.w20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Manual Backup ──────────────────────────────
            _sectionHeader(l.backupRestoreTitle),
            SizedBox(height: AppH.h12),
            _card(cs, [
              _infoRow(
                cs,
                icon: Icons.history,
                label: l.lastBackup,
                value: _lastManualBackup != null
                    ? DateFormat(
                        'dd MMM yyyy • hh:mm a',
                      ).format(_lastManualBackup!.toLocal())
                    : l.never,
              ),
              const Divider(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isExporting ? null : _handleExport,
                  icon: _isExporting
                      ? SizedBox(
                          width: AppW.w16,
                          height: AppH.h16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_outlined),
                  label: Text(
                    _isExporting ? l.onboardingRestoring : l.backupNow,
                  ),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppH.h14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppR.r12),
                    ),
                  ),
                ),
              ),
            ]),
            SizedBox(height: AppH.h24),

            // ── Restore ────────────────────────────────────
            _sectionHeader(l.restoreDialogTitle),
            SizedBox(height: AppH.h12),
            _card(cs, [
              Text(
                'Choose a .json backup file from your device, Google Drive, or any shared location.',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: AppSp.sp13,
                  height: 1.5,
                ),
              ),
              SizedBox(height: AppH.h16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isImporting ? null : _handleImport,
                  icon: _isImporting
                      ? SizedBox(
                          width: AppW.w16,
                          height: AppH.h16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined),
                  label: Text(
                    _isImporting ? l.onboardingRestoring : l.restoreFromFile,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppH.h14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppR.r12),
                    ),
                  ),
                ),
              ),
            ]),
            SizedBox(height: AppH.h24),

            // ── Auto Backup ────────────────────────────────
            _sectionHeader(l.autoBackup),
            SizedBox(height: AppH.h12),
            _card(cs, [
              // Toggle row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.autoBackup,
                          style: TextStyle(
                            fontSize: AppSp.sp15,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurface,
                          ),
                        ),
                        SizedBox(height: AppH.h2),
                        Text(
                          'Saves backups automatically to a folder you choose',
                          style: TextStyle(
                            fontSize: AppSp.sp12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(value: _autoEnabled, onChanged: _onToggleAuto),
                ],
              ),

              // ── SAF folder status banner (Android only) ──
              if (Platform.isAndroid) ...[
                SizedBox(height: AppH.h12),
                _safFolderBanner(cs, l),
              ],

              // ── Frequency & run controls (when enabled) ──
              if (_autoEnabled) ...[
                const Divider(height: 24),
                Text(
                  l.backupFreq,
                  style: TextStyle(
                    fontSize: AppSp.sp13,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: AppH.h10),
                Wrap(
                  spacing: 8,
                  children: AutoBackupManager.frequencyOptions.map((days) {
                    final selected = _autoFrequency == days;
                    return ChoiceChip(
                      label: Text(_frequencyLabel(days, l)),
                      selected: selected,
                      onSelected: (_) => _onFrequencyChanged(days),
                      selectedColor: cs.primaryContainer,
                      labelStyle: TextStyle(
                        color: selected
                            ? cs.onPrimaryContainer
                            : cs.onSurfaceVariant,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: AppH.h12),
                _infoRow(
                  cs,
                  icon: Icons.schedule_outlined,
                  label: l.lastBackup,
                  value: _lastAutoBackup != null
                      ? DateFormat(
                          'dd MMM yyyy • hh:mm a',
                        ).format(_lastAutoBackup!.toLocal())
                      : l.never,
                ),
                SizedBox(height: AppH.h12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isRunningAutoBackup ? null : _runAutoBackupNow,
                    icon: _isRunningAutoBackup
                        ? SizedBox(
                            width: AppW.w14,
                            height: AppH.h14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.play_arrow_rounded, size: AppSp.sp18),
                    label: Text(
                      _isRunningAutoBackup ? l.onboardingRestoring : l.backupNow,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppH.h12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppR.r10),
                      ),
                    ),
                  ),
                ),
              ],
            ]),
            SizedBox(height: AppH.h32),
          ],
        ),
      ),
    );
  }

  // ── SAF folder banner widget ─────────────────────────────────

  Widget _safFolderBanner(ColorScheme cs, AppLocalizations l) {
    final hasFolder = _savedFolderUri != null;

    if (hasFolder) {
      // ── Folder chosen: show path + change button ───────────
      return Container(
        padding: EdgeInsets.all(AppW.w12),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppR.r10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: AppSp.sp18,
              color: cs.primary,
            ),
            SizedBox(width: AppW.w8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backup folder',
                    style: TextStyle(
                      fontSize: AppSp.sp11,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppH.h2),
                  Text(
                    _folderDisplayName(_savedFolderUri!),
                    style: TextStyle(
                      fontSize: AppSp.sp12,
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: AppW.w8),
            TextButton(
              onPressed: _isPickingFolder ? null : () => _pickFolder(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: AppW.w10,
                  vertical: AppH.h4,
                ),
                minimumSize: Size.zero,
              ),
              child: Text(
                'Change',
                style: TextStyle(fontSize: AppSp.sp12, color: cs.primary),
              ),
            ),
          ],
        ),
      );
    } else {
      // ── No folder chosen: prompt ────────────────────────────
      return GestureDetector(
        onTap: _isPickingFolder ? null : () => _pickFolder(),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppW.w12,
            vertical: AppH.h10,
          ),
          decoration: BoxDecoration(
            color: cs.errorContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppR.r10),
            border: Border.all(
              color: cs.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              _isPickingFolder
                  ? SizedBox(
                      width: AppW.w16,
                      height: AppH.h16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.folder_off_outlined,
                      size: AppSp.sp16,
                      color: cs.error,
                    ),
              SizedBox(width: AppW.w8),
              Expanded(
                child: Text(
                  'Tap to choose a backup folder',
                  style: TextStyle(
                    fontSize: AppSp.sp12,
                    color: cs.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppSp.sp12,
                color: cs.error,
              ),
            ],
          ),
        ),
      );
    }
  }

  // ── Helpers ─────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: AppSp.sp18, fontWeight: FontWeight.w600),
    );
  }

  Widget _card(ColorScheme cs, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppW.w18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppR.r16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(
    ColorScheme cs, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: AppSp.sp16, color: cs.onSurfaceVariant),
        SizedBox(width: AppW.w8),
        Text(
          '$label: ',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: AppSp.sp13),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
