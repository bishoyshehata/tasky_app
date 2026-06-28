import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/utils/picker_manager.dart';
import 'package:tasky/data/models/user_model.dart';
import 'dart:convert';
import 'package:tasky/presentation/screens/splash_screen.dart';
import 'package:tasky/presentation/screens/user_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onUserChanged;

  const ProfileScreen({super.key, required this.onUserChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    _loadData();
  }

  UserModel? userModel;

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final userJson = prefs.getString('user');

    if (userJson != null) {
      setState(() {
        userModel = UserModel.fromJson(jsonDecode(userJson));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,

        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          children: [
            // Avatar Container
            Stack(
              children: [
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E1E1E),
                    border: Border.all(color: Colors.transparent, width: 2),
                  ),
                  child: ClipOval(
                    child: (userModel?.profileImagePath != null)
                        ? Image.file(
                            File(userModel!.profileImagePath!),
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.white,
                          ),
                  ),
                ),

                // Camera Icon Overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A2A),
                    ),
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFFD1D5DB), // text-gray-300
                      size: 16,
                    ),
                    onPressed: () => _showImagePickerDialog(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Identity Info
            Text(
              userModel?.name ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userModel?.motivationQuote ?? '',
              style: TextStyle(
                color: Color(0xFF9CA3AF), // text-gray-400
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 40),

            // Settings List
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  'Profile Info',
                  style: TextStyle(
                    color: Color(0xFFF3F4F6), // text-gray-100
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Menu Items
            _buildMenuItem(
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
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF2ECC71), // Green toggle state
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFF333333),
              ),
            ),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Log Out',
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('user');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                );
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1)
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? Colors.red[400]
                  : const Color(0xFF9CA3AF), // text-gray-400
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6B7280), // text-gray-500
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

    setState(() {
      userModel = userModel!.copyWith(profileImagePath: image.path);
    });

    await _saveUserData();
    widget.onUserChanged();
  }

  Future<void> pickImageFromCamera() async {
    final image = await PickerManager.pickImage(source: ImageSource.camera);

    if (image == null) return;

    setState(() {
      userModel = userModel!.copyWith(profileImagePath: image.path);
    });

    await _saveUserData();
    widget.onUserChanged();
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF1E1E1E),
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              tileColor: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Icon(Icons.photo, color: Colors.white),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                await pickImageFromGallery();
              },
            ),
            const SizedBox(height: 6),
            ListTile(
              tileColor: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Icon(Icons.camera_alt, color: Colors.white),
              title: Text(
                'Take from Camera',
                style: TextStyle(color: Colors.white),
              ),
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
    final prefs = await SharedPreferences.getInstance();

    if (userModel == null) return;

    await prefs.setString('user', jsonEncode(userModel!.toJson()));
  }
}
