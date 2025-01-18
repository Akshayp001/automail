import 'package:automail/screens/home_screen.dart';
import 'package:automail/screens/login_screen.dart';
import 'package:automail/screens/settings_screen.dart';
import 'package:automail/screens/splash_screen.dart';
import 'package:automail/services/app_version_service.dart';
import 'package:automail/utils/bindings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'screens/email_compose_screen.dart';
import 'utils/theme/theme_data.dart';

// Define route names as constants to avoid typos
class Routes {
  static const String login = '/login';
  static const String emailComposer = '/compose';
  static const String home = '/home';
  static const String splash = '/';
  static const String settings = '/smtp-settings';
}

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.emailComposer,
      page: () => EmailComposerScreen(),
      binding: EmailComposerBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: Routes.splash,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => SettingsScreen(),
    ),
  ];
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      final Uri? initialLink = await _appLinks.getInitialLink();
      if (initialLink != null && initialLink.scheme == 'mailto') {
        setState(() {
          _initialEmail = initialLink.path;
        });
      }

      _appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null && uri.scheme == 'mailto') {
          setState(() {
            _initialEmail = uri.path;
          });
          _navigateToEmailComposer(_initialEmail);
        }
      });
    } catch (e) {
      print('Error initializing deep links: $e');
    }
  }

  void _navigateToEmailComposer(String? email) {
    Get.offAllNamed(Routes.emailComposer, arguments: {'initialEmail': email});
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AutoMail',
      theme: buildPurpleTheme(),

      initialRoute: Routes.splash,
      // home: SplashScreen(),
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
