import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/presentation/screens/main_navigation_Screen.dart';
import 'package:tasky/core/theme/app_sizes.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToInitialRoute();
  }

  Future<void> _navigateToInitialRoute() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');

    if (!mounted) return;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainNavigationScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/logo.svg', width: AppW.w120, height: AppH.h120),
            SizedBox(height: AppH.h24),
            Text(
              'Tasky',
              style: TextStyle(
                fontSize: AppSp.sp32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
