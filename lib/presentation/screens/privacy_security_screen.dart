import 'package:flutter/material.dart';
import 'package:engez/core/theme/app_sizes.dart';
import 'package:engez/l10n/app_localizations.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.privacyTitle)),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppW.w20,
          vertical: AppH.h24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Icon ──────────────────────────────────────
            Center(
              child: Container(
                width: AppW.w120,
                height: AppH.h120,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: AppSp.sp60,
                  color: cs.primary,
                ),
              ),
            ),
            SizedBox(height: AppH.h32),

            _SectionCard(
              icon: Icons.storage_outlined,
              title: l.privacyDataTitle,
              body: l.privacyDataBody,
              cs: cs,
            ),
            SizedBox(height: AppH.h16),
            _SectionCard(
              icon: Icons.backup_outlined,
              title: l.privacyBackupTitle,
              body: l.privacyBackupBody,
              cs: cs,
            ),
            SizedBox(height: AppH.h16),
            _SectionCard(
              icon: Icons.notifications_outlined,
              title: l.privacyNotifTitle,
              body: l.privacyNotifBody,
              cs: cs,
            ),
            SizedBox(height: AppH.h16),

            // ── Permissions ───────────────────────────────────
            _PermissionsCard(l: l, cs: cs),

            SizedBox(height: AppH.h16),
            _SectionCard(
              icon: Icons.mail_outline,
              title: l.privacyContactTitle,
              body: l.privacyContactBody,
              cs: cs,
            ),

            SizedBox(height: AppH.h32),
            Center(
              child: Text(
                l.privacyVersion,
                style: TextStyle(
                  fontSize: AppSp.sp12,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: AppH.h16),
          ],
        ),
      ),
    );
  }
}

// ── Reusable section card ──────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.cs,
  });

  final IconData icon;
  final String title;
  final String body;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppW.w16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppR.r16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSp.sp22, color: cs.primary),
          SizedBox(width: AppW.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSp.sp15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppH.h6),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: AppSp.sp13,
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Permissions list card ──────────────────────────────────────────────────
class _PermissionsCard extends StatelessWidget {
  const _PermissionsCard({required this.l, required this.cs});
  final AppLocalizations l;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final items = [
      l.privacyPermStorage,
      l.privacyPermNotif,
      l.privacyPermCamera,
    ];

    return Container(
      padding: EdgeInsets.all(AppW.w16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppR.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, size: AppSp.sp22, color: cs.primary),
              SizedBox(width: AppW.w12),
              Text(
                l.privacyPermTitle,
                style: TextStyle(
                  fontSize: AppSp.sp15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppH.h10),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: AppH.h8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: AppSp.sp14,
                    color: cs.primary,
                  ),
                  SizedBox(width: AppW.w8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: AppSp.sp13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
