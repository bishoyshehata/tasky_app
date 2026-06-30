import 'dart:convert';

import 'package:engez/core/l10n/app_locale_notifier.dart';
import 'package:engez/core/theme/app_sizes.dart';
import 'package:engez/core/theme/app_theme_notifier.dart';
import 'package:engez/core/utils/picker_manager.dart';
import 'package:engez/data/models/task_model.dart';
import 'package:engez/data/models/user_model.dart';
import 'package:engez/l10n/app_localizations.dart';
import 'package:engez/presentation/screens/archived_tasks_screen.dart';
import 'package:engez/presentation/screens/backup_restore_screen.dart';
import 'package:engez/presentation/screens/privacy_security_screen.dart';
import 'package:engez/presentation/screens/splash_screen.dart';
import 'package:engez/presentation/screens/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onUserChanged;
  final List<TaskModel> tasks;
  final ValueChanged<List<TaskModel>> onTasksChanged;

  const ProfileScreen({
    super.key,
    required this.onUserChanged,
    required this.tasks,
    required this.onTasksChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      setState(() {
        userModel = UserModel.fromJson(jsonDecode(userJson));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Text(l.profileTitle),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppW.w24, vertical: AppH.h24),
        child: Column(
          children: [
            // ── Avatar ─────────────────────────────────────────
            Stack(
              children: [
                Container(
                  width: AppW.w128,
                  height: AppH.h128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceContainerHighest,
                    border: Border.all(color: Colors.transparent, width: 2),
                  ),
                  child: ClipOval(
                    child: (userModel?.profileImageBytes != null)
                        ? Image.memory(
                            userModel!.profileImageBytes!,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.person,
                            size: AppSp.sp48,
                            color: colorScheme.onSurface,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: AppSp.sp16,
                    ),
                    onPressed: _showImagePickerDialog,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppH.h24),

            // ── Identity ────────────────────────────────────────
            Text(
              userModel?.name ?? '',
              style: TextStyle(
                fontSize: AppSp.sp24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: AppH.h8),
            Text(
              userModel?.motivationQuote ?? '',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: AppSp.sp14,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: AppH.h40),

            // ── Section Label ───────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppW.w4),
                child: Text(
                  l.profileSectionLabel,
                  style: TextStyle(
                    fontSize: AppSp.sp18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppH.h16),

            // ── Menu Items ──────────────────────────────────────
            _buildMenuItem(
              context: context,
              icon: Icons.person_outline,
              title: l.menuUserDetails,
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UserDetailsScreen()),
                );
                if (result != null) {
                  _loadData();
                  widget.onUserChanged();
                }
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.archive_outlined,
              title: l.menuArchivedTasks,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ArchivedTasksScreen(
                      tasks: widget.tasks,
                      onTasksChanged: widget.onTasksChanged,
                    ),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.backup_outlined,
              title: l.menuBackupRestore,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
              ),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.shield_outlined,
              title: l.menuPrivacySecurity,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PrivacySecurityScreen(),
                ),
              ),
            ),
            // ── Language toggle ──────────────────────────────────
            _buildMenuItem(
              context: context,
              icon: Icons.language_outlined,
              title: l.menuLanguage,
              trailing: ValueListenableBuilder<Locale>(
                valueListenable: AppLocaleNotifier.instance,
                builder: (_, locale, __) => GestureDetector(
                  onTap: () => AppLocaleNotifier.instance.toggle(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppW.w12,
                      vertical: AppH.h4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppR.r20),
                    ),
                    child: Text(
                      locale.languageCode == 'ar' ? 'العربية' : 'English',
                      style: TextStyle(
                        fontSize: AppSp.sp13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.dark_mode_outlined,
              title: l.menuDarkMode,
              trailing: ValueListenableBuilder<ThemeMode>(
                valueListenable: AppThemeNotifier.instance,
                builder: (_, themeMode, __) => Switch(
                  value: AppThemeNotifier.instance.isDark,
                  onChanged: (_) => AppThemeNotifier.instance.toggle(),
                ),
              ),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.logout,
              title: l.menuLogOut,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user');
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SplashScreen()),
                  );
                }
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppH.h16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colorScheme.outline, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
              size: AppSp.sp24,
            ),
            SizedBox(width: AppW.w16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppSp.sp16,
                  fontWeight: FontWeight.w400,
                  color: isDestructive ? colorScheme.error : null,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                  size: AppSp.sp20,
                ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImageFromGallery() async {
    final image = await PickerManager.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    final base64Str = base64Encode(bytes);
    setState(() {
      userModel = userModel!.copyWith(profileImageBase64: base64Str);
    });
    await _saveUserData();
    widget.onUserChanged();
  }

  Future<void> pickImageFromCamera() async {
    final image = await PickerManager.pickImage(source: ImageSource.camera);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    final base64Str = base64Encode(bytes);
    setState(() {
      userModel = userModel!.copyWith(profileImageBase64: base64Str);
    });
    await _saveUserData();
    widget.onUserChanged();
  }

  void _showImagePickerDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppW.w20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              tileColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppR.r12),
              ),
              leading: Icon(Icons.photo, color: colorScheme.onSurface),
              title: Text(l.galleryOption),
              onTap: () async {
                Navigator.pop(context);
                await pickImageFromGallery();
              },
            ),
            SizedBox(height: AppH.h6),
            ListTile(
              tileColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppR.r12),
              ),
              leading: Icon(Icons.camera_alt, color: colorScheme.onSurface),
              title: Text(l.cameraOption),
              onTap: () async {
                Navigator.pop(context);
                await pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveUserData() async {
    if (userModel == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(userModel!.toJson()));
  }
}
