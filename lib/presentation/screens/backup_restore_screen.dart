import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:engez/core/backup/auto_backup_manager.dart';
import 'package:engez/core/backup/backup_model.dart';
import 'package:engez/core/backup/backup_service.dart';
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

class _BackupRestoreScreenState extends State<BackupRestoreScreen>
    with WidgetsBindingObserver {
  final _backupService = BackupService();
  late final _createUseCase = CreateBackupUseCase(_backupService);
  late final _restoreUseCase = RestoreBackupUseCase(_backupService);

  bool _isExporting = false;
  bool _isImporting = false;
  bool _isRunningAutoBackup = false;
  bool _autoEnabled = false;
  bool _hasFullStorageAccess = false;
  bool _waitingForPermission = false;
  int _autoFrequency = 1;
  DateTime? _lastManualBackup;
  DateTime? _lastAutoBackup;
  String? _lastAutoBackupPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
    _checkStoragePermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called when app resumes (e.g. user returns from Settings).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForPermission) {
      _waitingForPermission = false;
      _checkStoragePermission().then((_) {
        if (_hasFullStorageAccess) _runAutoBackupNow();
      });
    }
  }

  Future<void> _checkStoragePermission() async {
    if (!Platform.isAndroid) {
      if (mounted) setState(() => _hasFullStorageAccess = true);
      return;
    }
    final granted = await Permission.manageExternalStorage.isGranted;
    if (mounted) setState(() => _hasFullStorageAccess = granted);
  }

  Future<void> _loadSettings() async {
    final enabled = await AutoBackupManager.isEnabled();
    final freq = await AutoBackupManager.getFrequencyDays();
    final lastManual = await AutoBackupManager.getLastManualBackupAt();
    final lastAuto = await AutoBackupManager.getLastBackupAt();
    final lastPath = await AutoBackupManager.getLastBackupPath();
    await _checkStoragePermission();
    if (mounted) {
      setState(() {
        _autoEnabled = enabled;
        _autoFrequency = freq;
        _lastManualBackup = lastManual;
        _lastAutoBackup = lastAuto;
        _lastAutoBackupPath = lastPath;
      });
    }
  }

  // ── Export ──────────────────────────────────────────────────

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    try {
      await _createUseCase.execute();
      if (mounted) {
        _loadSettings(); // refresh last backup date
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
            // Handle bar
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

            // Header
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

            // Stats
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

            // Merge
            _strategyButton(
              ctx: ctx,
              icon: Icons.merge_outlined,
              label: l.backupMerge,
              subtitle: l.backupMergeDesc,
              color: colorScheme.primary,
              onTap: () => _applyRestore(ctx, preview, RestoreStrategy.merge),
            ),
            SizedBox(height: AppH.h10),

            // Replace
            _strategyButton(
              ctx: ctx,
              icon: Icons.swap_horiz_rounded,
              label: l.backupReplace,
              subtitle: l.backupReplaceDesc,
              color: colorScheme.error,
              onTap: () => _confirmReplace(ctx, preview, l),
            ),
            SizedBox(height: AppH.h10),

            // Cancel
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
      // Trigger global UI refresh
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
    if (value) await _runAutoBackupNow(silent: true);
  }

  Future<void> _runAutoBackupNow({bool silent = false}) async {
    // On Android, prefer public storage — request permission if not yet granted.
    if (Platform.isAndroid && !_hasFullStorageAccess) {
      await _requestFullStorageAccess();
      return; // Will auto-resume via didChangeAppLifecycleState once granted.
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

  /// Shows an explanation dialog then redirects to the All Files Access screen.
  Future<void> _requestFullStorageAccess() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.backupStoragePermissionTitle),
        content: Text(l.backupStoragePermissionDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.continueBtn),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _waitingForPermission = true);
      await Permission.manageExternalStorage.request();
      // App will resume → didChangeAppLifecycleState handles the rest.
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
            Platform.isAndroid
                ? Column(
                    children: [
                      _sectionHeader(l.autoBackup),
                      SizedBox(height: AppH.h12),
                      _card(cs, [
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
                                    'Automatically saves a local backup',
                                    style: TextStyle(
                                      fontSize: AppSp.sp12,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _autoEnabled,
                              onChanged: _onToggleAuto,
                            ),
                          ],
                        ),
                        // ── Storage Access Banner ────────────────────
                        if (Platform.isAndroid) ...[
                          SizedBox(height: AppH.h12),
                          GestureDetector(
                            onTap: _hasFullStorageAccess
                                ? null
                                : _requestFullStorageAccess,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppW.w12,
                                vertical: AppH.h8,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(AppR.r10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.folder_open_rounded,
                                    size: AppSp.sp16,
                                    color: cs.primary,
                                  ),
                                  SizedBox(width: AppW.w8),
                                  Expanded(
                                    child: Text(
                                      l.backupAutoBanner,
                                      style: TextStyle(
                                        fontSize: AppSp.sp12,
                                        color: cs.onPrimaryContainer,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                            children: AutoBackupManager.frequencyOptions.map((
                              days,
                            ) {
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
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
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
                              onPressed: _isRunningAutoBackup
                                  ? null
                                  : _runAutoBackupNow,
                              icon: _isRunningAutoBackup
                                  ? SizedBox(
                                      width: AppW.w14,
                                      height: AppH.h14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.play_arrow_rounded,
                                      size: AppSp.sp18,
                                    ),
                              label: Text(
                                _isRunningAutoBackup
                                    ? l.onboardingRestoring
                                    : l.backupNow,
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppH.h12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppR.r10),
                                ),
                              ),
                            ),
                          ),
                          if (_lastAutoBackupPath != null) ...[
                            SizedBox(height: AppH.h12),
                            Container(
                              padding: EdgeInsets.all(AppW.w12),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(AppR.r10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.folder_outlined,
                                    size: AppSp.sp16,
                                    color: cs.primary,
                                  ),
                                  SizedBox(width: AppW.w8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l.backupSavedLocal,
                                          style: TextStyle(
                                            fontSize: AppSp.sp11,
                                            color: cs.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: AppH.h2),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: AppW.w6),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ]),
                      SizedBox(height: AppH.h32),
                    ],
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
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
      padding: EdgeInsets.all(
        AppW.w18,
      ), // Let's add AppW.w18 instead of fallback
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
