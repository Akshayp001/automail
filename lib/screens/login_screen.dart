// login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Image.asset(
                  'assets/icons/appicont.png',
                  width: 180,
                  height: 180,
                ),
                const SizedBox(height: 24),

                // App Name
                Text(
                  'AutoMail',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Slogan
                Text(
                  'Create And Use Email Templates',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color.fromARGB(255, 65, 58, 58),
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 48),

                // Google Sign In Button
                Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.purple.shade50,
                        foregroundColor: Colors.black87,
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/google_logo.png',
                            height: 24,
                          ),
                          const SizedBox(width: 12),
                          controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
