import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/presentation/screens/home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(0),
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
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Full Name',
                          style: TextStyle(
                            color: Color(0xFFFFFCFC),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller,
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
                            hintText: 'e.g. Sarah Khalid',
                            hintStyle: TextStyle(
                              color: Color(0xFF6D6D6D),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
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
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                'name',
                                controller.value.text,
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF15B86C),
                            fixedSize: Size(screenWidth, 40),
                          ),
                          child: Text(
                            'Let’s Get Started',
                            style: TextStyle(
                              color: Color(0xFFFFFCFC),
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
