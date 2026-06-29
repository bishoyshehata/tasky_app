import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/data/models/user_model.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final nameController = TextEditingController();
  final quoteController = TextEditingController();
  final nameFocus = FocusNode();
  final quoteFocus = FocusNode();
  bool _isButtonEnabled = false;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_updateButtonState);
    quoteController.addListener(_updateButtonState);
    _loadData();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled =
          nameController.text.isNotEmpty || quoteController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    nameController.removeListener(_updateButtonState);
    quoteController.removeListener(_updateButtonState);
    nameController.dispose();
    quoteController.dispose();
    nameFocus.dispose();
    quoteFocus.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Name',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    focusNode: nameFocus,
                    textInputAction: TextInputAction.done,
                    maxLines: 1,
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: userModel?.name ?? 'Write Your Name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Motivation Quote',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    focusNode: quoteFocus,
                    textInputAction: TextInputAction.done,
                    maxLines: 5,
                    controller: quoteController,
                    decoration: InputDecoration(
                      hintText: userModel?.motivationQuote ??
                          'Write a quote that motivates you to do your tasks.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isButtonEnabled
                ? () async {
                    final user = UserModel(
                      name: nameController.text.isNotEmpty
                          ? nameController.text
                          : userModel?.name ?? 'Write Your Name',
                      motivationQuote: quoteController.text.isNotEmpty
                          ? quoteController.text
                          : userModel?.motivationQuote,
                      profileImagePath: userModel?.profileImagePath ?? '',
                    );
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('user', jsonEncode(user.toJson()));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User details updated successfully'),
                        ),
                      );
                      Navigator.pop(context, user);
                    }
                  }
                : null,
            label: const Text('Save Changes', style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(346, 40),
            ),
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }
}
