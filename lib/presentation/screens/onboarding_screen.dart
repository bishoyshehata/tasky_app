import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:engez/core/backup/backup_model.dart';
import 'package:engez/core/backup/backup_service.dart';
import 'package:engez/core/theme/app_sizes.dart';
import 'package:engez/data/models/user_model.dart';
import 'package:engez/l10n/app_localizations.dart';
import 'package:engez/presentation/screens/main_navigation_Screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isRestoring = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _restoreFromBackup() async {
    setState(() => _isRestoring = true);

    BackupPreview? preview;
    try {
      preview = await BackupService().pickAndPreview();
    } catch (e) {
      if (mounted) {
        _showSnack('Could not read backup: $e', isError: true);
      }
      setState(() => _isRestoring = false);
      return;
    }

    if (preview == null || !mounted) {
      setState(() => _isRestoring = false);
      return;
    }

    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(l.restoreDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.restoreDialogContent(preview!.taskCount),
                style: TextStyle(fontSize: AppSp.sp15),
              ),
              SizedBox(height: AppH.h6),
              Text(
                l.restoreDialogCreated(_fmtDate(preview.createdAt)),
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: AppSp.sp13,
                ),
              ),
              SizedBox(height: AppH.h14),
              Text(
                l.restoreDialogWarning,
                style: TextStyle(fontSize: AppSp.sp13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.restore),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      setState(() => _isRestoring = false);
      return;
    }

    try {
      await BackupService().applyRestore(preview, RestoreStrategy.replace);

      final prefs = await SharedPreferences.getInstance();
      final existingUser = prefs.getString('user');
      if (existingUser == null) {
        final name = controller.text.trim().isNotEmpty
            ? controller.text.trim()
            : (preview.model.user?.name ?? 'User');
        final user = UserModel(
          name: name,
          motivationQuote:
              preview.model.user?.motivationQuote ??
              'You got this, Just do your best',
          profileImageBase64: preview.model.user?.profileImageBase64,
        );
        await prefs.setString('user', jsonEncode(user.toJson()));
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (mounted)
        _showSnack(
          '${AppLocalizations.of(context).restoreFailed}: $e',
          isError: true,
        );
      setState(() => _isRestoring = false);
    }
  }

  String _fmtDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppR.r10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppW.w16),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/logo.svg',
                        width: AppW.w60,
                        height: AppH.h60,
                      ),
                      SizedBox(width: AppW.w16),
                      Text(
                        'Engez',
                        style: TextStyle(
                          fontSize: AppSp.sp28,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppH.h118),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l.onboardingWelcome,
                        style: TextStyle(
                          fontSize: AppSp.sp24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: AppW.w16),
                      SvgPicture.asset(
                        'assets/images/hand.svg',
                        width: AppW.w40,
                        height: AppH.h40,
                      ),
                    ],
                  ),
                  SizedBox(height: AppH.h8),
                  Text(
                    l.onboardingSubtitle,
                    style: TextStyle(
                      fontSize: AppSp.sp16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: AppH.h24),
                  SvgPicture.asset(
                    'assets/images/onboard_image.svg',
                    width: AppW.w215,
                    height: AppH.h204,
                  ),
                  SizedBox(height: AppH.h28),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.onboardingFullName,
                          style: TextStyle(
                            fontSize: AppSp.sp16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: AppH.h8),
                        TextFormField(
                          controller: controller,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                          },
                          decoration: InputDecoration(
                            hintText: l.onboardingNameHint,
                          ),
                          validator: (value) {
                            if (value?.trim().isEmpty ?? false) {
                              return l.onboardingValidateName;
                            } else if (value!.trim().length < 3) {
                              return l.onboardingValidateNameLength;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppH.h24),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final user = UserModel(
                                name: controller.value.text,
                                motivationQuote:
                                    'You got this, Just do your best',
                                profileImageBase64: null,
                              );
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                'user',
                                jsonEncode(user.toJson()),
                              );
                              if (context.mounted) {
                                FocusScope.of(context).unfocus();

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MainNavigationScreen(),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(screenWidth, AppH.h40),
                          ),
                          child: Text(
                            l.onboardingGetStarted,
                            style: TextStyle(
                              fontSize: AppSp.sp20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // ── Restore from backup ─────────────────────
                        SizedBox(height: AppH.h16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isRestoring ? null : _restoreFromBackup,
                            icon: _isRestoring
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.primary,
                                    ),
                                  )
                                : const Icon(Icons.restore_outlined),
                            label: Text(
                              _isRestoring
                                  ? l.onboardingRestoring
                                  : l.onboardingRestoreBackup,
                              style: TextStyle(fontSize: AppSp.sp15),
                            ),
                            style: OutlinedButton.styleFrom(
                              fixedSize: Size(screenWidth, AppH.h40),
                            ),
                          ),
                        ),
                        SizedBox(height: AppH.h8),
                        Center(
                          child: Text(
                            l.onboardingRestoreHint,
                            style: TextStyle(
                              fontSize: AppSp.sp12,
                              color: cs.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppH.h24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
