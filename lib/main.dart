import 'package:automail/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'screens/email_compose_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const EmailApp());
}

class EmailApp extends StatefulWidget {
  const EmailApp({super.key});

  @override
  State<EmailApp> createState() => _EmailAppState();
}

class _EmailAppState extends State<EmailApp> {
  late final AppLinks _appLinks;
  String? _initialEmail;

  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
  }

  void _initializeDeepLinks() async {
    _appLinks = AppLinks();
    try {
      // Handle initial link when the app is launched via a deep link
      final Uri? initialLink = await _appLinks.getInitialLink();
      if (initialLink != null && initialLink.scheme == 'mailto') {
        setState(() {
          _initialEmail = initialLink.path; // Extract the email address
        });
      }

      // Handle incoming links while the app is in the foreground
      _appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null && uri.scheme == 'mailto') {
          setState(() {
            _initialEmail = uri.path; // Extract the email address
          });
          _navigateToEmailComposer(_initialEmail);
        }
      });
    } catch (e) {
      // Handle any errors
      print('Error initializing deep links: $e');
    }
  }

  void _navigateToEmailComposer(String? email) {
    Get.to(() => EmailComposerScreen(initialEmail: email));
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AutoMail',
      theme: buildPurpleTheme(),
      home: _initialEmail != null
          ? EmailComposerScreen(initialEmail: _initialEmail)
          : SplashScreen(),
    );
  }
}

ThemeData buildPurpleTheme() {
  return ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.purple,
    primaryColor: Colors.purple[700],
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: const AppBarTheme(
      toolbarHeight: 80,
      backgroundColor: Colors.purple,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4,
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            return Colors.purple[600];
          },
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.purple[200]!.withOpacity(0.3);
            }
            return null;
          },
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(
        color: Colors.purple,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.purple, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.amber),
  );
}
