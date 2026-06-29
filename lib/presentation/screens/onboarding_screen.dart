import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/data/models/user_model.dart';
import 'package:tasky/presentation/screens/main_navigation_Screen.dart';

class OnboardingScreen extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Tasky',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 118),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome To Taskey',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SvgPicture.asset(
                        'assets/images/hand.svg',
                        width: 40,
                        height: 40,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your productivity journey starts here.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 24),
                  SvgPicture.asset(
                    'assets/images/onboard_image.svg',
                    width: 215,
                    height: 204,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final user = UserModel(
                                name: controller.value.text,
                                motivationQuote:
                                    'You got this, Just do your best',
                                profileImagePath: null,
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
                                        MainNavigationScreen(),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(screenWidth, 40),
                          ),
                          child: const Text(
                            'Let\'s Get Started',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
