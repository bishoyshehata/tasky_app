import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/backup/backup_model.dart';
import 'package:tasky/core/backup/backup_service.dart';
import 'package:tasky/core/backup/backup_validator.dart';
import 'package:tasky/data/models/user_model.dart';
import 'package:tasky/presentation/screens/main_navigation_Screen.dart';
import 'package:tasky/core/theme/app_sizes.dart';

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

    // ── Confirm ──────────────────────────────────────────────
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Restore Backup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Found ${preview!.taskCount} task${preview.taskCount != 1 ? 's' : ''} in this backup.',
                style: TextStyle(fontSize: AppSp.sp15),
              ),
              SizedBox(height: AppH.h6),
              Text(
                'Created: ${_fmtDate(preview.createdAt)}',
                style:
                    TextStyle(color: cs.onSurfaceVariant, fontSize: AppSp.sp13),
              ),
              SizedBox(height: AppH.h14),
              Text(
                'All tasks will be restored and you\'ll go straight to the app.',
                style: TextStyle(fontSize: AppSp.sp13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Restore'),
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
      // Apply replace restore
      await BackupService().applyRestore(preview, RestoreStrategy.replace);

      // User profile is already saved by applyRestore if backup contained one.
      // Only create a fallback user if none was in the backup.
      final prefs = await SharedPreferences.getInstance();
      final existingUser = prefs.getString('user');
      if (existingUser == null) {
        final name = controller.text.trim().isNotEmpty
            ? controller.text.trim()
            : (preview.model.user?.name ?? 'User');
        final user = UserModel(
          name: name,
          motivationQuote:
              preview.model.user?.motivationQuote ?? 'You got this, Just do your best',
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
      if (mounted) _showSnack('Restore failed: $e', isError: true);
      setState(() => _isRestoring = false);
    }
  }

  String _fmtDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppR.r10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cs = Theme.of(context).colorScheme;

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
                        'Tasky',
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
                        'Welcome To Taskey',
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
                    'Your productivity journey starts here.',
                    style: TextStyle(fontSize: AppSp.sp16, fontWeight: FontWeight.w400),
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
                          'Full Name',
                          style: TextStyle(
                            fontSize: AppSp.sp16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: AppH.h8),
                        TextFormField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Sarah Khalid',
                          ),
                          validator: (value) {
                            if (value?.trim().isEmpty ?? false) {
                              return 'Please enter your full name';
                            } else if (value!.trim().length < 3) {
                              return 'Please enter a valid full name';
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
                            'Let\'s Get Started',
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
                                  ? 'Restoring...'
                                  : 'Restore from Backup',
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
                            'Have a backup file? Restore everything in one tap.',
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


