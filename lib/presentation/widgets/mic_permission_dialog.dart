import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:engez/l10n/app_localizations.dart';
import 'package:engez/core/theme/app_sizes.dart';

class MicPermissionDialog extends StatefulWidget {
  const MicPermissionDialog({super.key});

  @override
  State<MicPermissionDialog> createState() => _MicPermissionDialogState();
}

class _MicPermissionDialogState extends State<MicPermissionDialog> with WidgetsBindingObserver {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && !_isChecking) {
      _isChecking = true;
      final micStatus = await Permission.microphone.status;
      _isChecking = false;

      if (micStatus.isGranted && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppR.r16)),
      title: Row(
        children: [
          Icon(Icons.mic_off_outlined, color: cs.error, size: AppSp.sp28),
          SizedBox(width: AppW.w8),
          Expanded(
            child: Text(
              l.micPermissionTitle,
              style: TextStyle(fontSize: AppSp.sp18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Text(
        l.micPermissionDesc,
        style: TextStyle(fontSize: AppSp.sp14, height: 1.5, color: cs.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            l.cancel,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: AppSp.sp14),
          ),
        ),
        FilledButton(
          onPressed: () {
            openAppSettings();
          },
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppR.r8)),
          ),
          child: Text(
            l.openSettings,
            style: TextStyle(fontSize: AppSp.sp14),
          ),
        ),
      ],
    );
  }
}
