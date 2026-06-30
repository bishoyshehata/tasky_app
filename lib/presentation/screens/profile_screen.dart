import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/theme/app_theme_notifier.dart';
import 'package:tasky/core/utils/picker_manager.dart';
import 'package:tasky/data/models/user_model.dart';
import 'dart:convert';
import 'package:tasky/presentation/screens/splash_screen.dart';
import 'package:tasky/presentation/screens/user_details_screen.dart';
import 'package:tasky/presentation/screens/backup_restore_screen.dart';
import 'package:tasky/presentation/screens/archived_tasks_screen.dart';
import 'package:tasky/data/models/task_model.dart';

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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          children: [
            // ── Avatar ─────────────────────────────────────────
            Stack(
              children: [
                Container(
                  width: 128,
                  height: 128,
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
                            size: 48,
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
                      size: 16,
                    ),
                    onPressed: _showImagePickerDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Identity ────────────────────────────────────────
            Text(
              userModel?.name ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userModel?.motivationQuote ?? '',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 40),

            // ── Section Label ───────────────────────────────────
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  'Profile Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Menu Items ──────────────────────────────────────
            _buildMenuItem(
              context: context,
              icon: Icons.person_outline,
              title: 'User Details',
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
              title: 'Archived Tasks',
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
              title: 'Backup & Restore',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BackupRestoreScreen(),
                ),
              ),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
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
              title: 'Log Out',
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
        padding: const EdgeInsets.symmetric(vertical: 16),
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
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
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

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              tileColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Icon(Icons.photo, color: colorScheme.onSurface),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await pickImageFromGallery();
              },
            ),
            const SizedBox(height: 6),
            ListTile(
              tileColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Icon(Icons.camera_alt, color: colorScheme.onSurface),
              title: const Text('Take from Camera'),
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
