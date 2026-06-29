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
      appBar: AppBar(title: const Text('User Details')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Name',
                    style: TextStyle(
                      color: Color(0xffFFFCFC),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 6),
                  TextFormField(
                    focusNode: nameFocus,
                    textInputAction: TextInputAction.done,
                    maxLines: 1,
                    controller: nameController,
                    cursorColor: Colors.white,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Color(0xFF282828),
                      filled: true,
                      hintText: userModel?.name ?? 'Write Your Name',
                      hintStyle: TextStyle(
                        color: Color(0xFF6D6D6D),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Motivation Quote',
                    style: TextStyle(
                      color: Color(0xffFFFCFC),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 6),
                  TextFormField(
                    focusNode: quoteFocus,
                    textInputAction: TextInputAction.done,
                    maxLines: 5,
                    controller: quoteController,
                    cursorColor: Colors.white,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Color(0xFF282828),
                      filled: true,
                      hintText:
                          userModel?.motivationQuote ??
                          'Write a quote that motivates you to do your tasks.',
                      hintStyle: TextStyle(
                        color: Color(0xFF6D6D6D),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isButtonEnabled
                ? () async {
                    String name = nameController.text;
                    String quote = quoteController.text;
                    final user = UserModel(
                      name: name.isNotEmpty
                          ? name
                          : userModel?.name ?? 'Write Your Name',
                      motivationQuote: quote.isNotEmpty
                          ? quote
                          : userModel?.motivationQuote,
                      profileImagePath: userModel?.profileImagePath ?? '',
                    );
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('user', jsonEncode(user.toJson()));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User details updated successfully'),
                          backgroundColor: Color(0xFF15B86C),
                        ),
                      );
                      Navigator.pop(context, user);
                    }
                  }
                : null,
            label: Text('Save Changes', style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF15B86C),
              foregroundColor: Color(0xffFFFCFC),
              disabledBackgroundColor: Color(0xFF15B86C).withOpacity(0.5),
              disabledForegroundColor: Color(0xffFFFCFC).withOpacity(0.5),
              fixedSize: Size(346, 40),
            ),
          ),
          SizedBox(height: 34),
        ],
      ),
    );
  }
}
