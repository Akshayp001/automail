import 'dart:async';
import 'package:automail/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Animation controllers
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  // Custom colors
  final Color primaryPurple = Color(0xFF6C63FF);
  final Color accentPink = Color(0xFFFF69B4);
  final Color backgroundColor = Color(0xFFF8F0FF);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward().whenComplete(() {
      Timer(Duration(milliseconds: 500), () async {
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          Get.offAllNamed('/home');
          return;
        }
        Get.offAllNamed('/login');

        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => HomeScreen()),
        // );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              Color(0xFFE8E0FF),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scale.value,
                child: FadeTransition(
                  opacity: _opacity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Logo
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: primaryPurple.withOpacity(0.2),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/icons/appicont.png',
                          height: 150,
                        ),
                      ),
                      SizedBox(height: 30),

                      // App Name
                      Text(
                        "AutoMail",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: primaryPurple,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: primaryPurple.withOpacity(0.3),
                              offset: Offset(0, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),

                      // Tagline
                      Text(
                        "Email Templates",
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryPurple.withOpacity(0.7),
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 40),

                      // Custom Loading Indicator
                      Container(
                        width: 50,
                        height: 50,
                        child: Stack(
                          children: [
                            CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(accentPink),
                              strokeWidth: 3,
                            ),
                            Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryPurple),
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                      Text(
                        "Loading...",
                        style: TextStyle(
                          color: primaryPurple.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
