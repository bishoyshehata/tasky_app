import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:engez/core/theme/app_sizes.dart';
import 'package:engez/data/models/user_model.dart';
import 'package:engez/l10n/app_localizations.dart';

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
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.userDetailsTitle)),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppW.w16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.userDetailsName,
                    style: TextStyle(fontSize: AppSp.sp18, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: AppH.h6),
                  TextFormField(
                    focusNode: nameFocus,
                    textInputAction: TextInputAction.done,
                    maxLines: 1,
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: userModel?.name ?? l.userDetailsNameHint,
                    ),
                  ),
                  SizedBox(height: AppH.h12),
                  Text(
                    l.userDetailsQuote,
                    style: TextStyle(fontSize: AppSp.sp18, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: AppH.h6),
                  TextFormField(
                    focusNode: quoteFocus,
                    textInputAction: TextInputAction.done,
                    maxLines: 5,
                    controller: quoteController,
                    decoration: InputDecoration(
                      hintText:
                          userModel?.motivationQuote ??
                          l.userDetailsQuoteHint,
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
                          : userModel?.name ?? l.userDetailsNameHint,
                      motivationQuote: quoteController.text.isNotEmpty
                          ? quoteController.text
                          : userModel?.motivationQuote,
                      profileImageBase64: userModel?.profileImageBase64,
                    );
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('user', jsonEncode(user.toJson()));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.userDetailsSave),
                        ),
                      );
                      Navigator.pop(context, user);
                    }
                  }
                : null,
            label: Text(l.userDetailsSave, style: TextStyle(fontSize: AppSp.sp14)),
            style: ElevatedButton.styleFrom(fixedSize: Size(AppW.w300 + AppW.w40, AppH.h40)),
          ),
          SizedBox(height: AppH.h34),
        ],
      ),
    );
  }
}
