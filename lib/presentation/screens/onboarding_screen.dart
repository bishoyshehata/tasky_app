import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
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
                      color: Color(0xFFFFFFFF),
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
                      color: Color(0xFFFFFCFC),
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
                style: TextStyle(
                  color: Color(0xFFFFFCFC),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),

              SvgPicture.asset(
                'assets/images/onboard_image.svg',
                width: 215,
                height: 204,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
