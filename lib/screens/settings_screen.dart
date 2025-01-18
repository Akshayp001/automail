// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import './../utils/input_decorations.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen>
//     with SingleTickerProviderStateMixin {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _prefs = SharedPreferences.getInstance();
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//   bool hidePassword = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadCredentials();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadCredentials() async {
//     final prefs = await _prefs;
//     setState(() {
//       _emailController.text = prefs.getString('email') ?? '';
//       _passwordController.text = prefs.getString('password') ?? '';
//     });
//   }

//   Future<void> _saveCredentials() async {
//     final prefs = await _prefs;
//     await prefs.setString('email', _emailController.text);
//     await prefs.setString('password', _passwordController.text);
//     _animationController.reset();
//     _animationController.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//         centerTitle: true, // Center the title for better balance
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Email Field with Icon
//               TextField(
//                 controller: _emailController,
//                 decoration: buildInputDecoration(
//                   labelText: 'Gmail Address',
//                   prefixIcon: CupertinoIcons.cloud_upload,
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 16),
//               // Password Field with Icon and Disclaimer
//               TextField(
//                 controller: _passwordController,
//                 decoration: buildInputDecoration(
//                   labelText: 'App Password',
//                   helperText:
//                       'Use Gmail App Password, not your account password',
//                   suffixIcon: InkWell(
//                     onTap: () {
//                       setState(() {
//                         hidePassword = !hidePassword;
//                       });
//                     },
//                     child: Icon(
//                       hidePassword == true
//                           ? CupertinoIcons.eye_slash
//                           : CupertinoIcons.eye,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//                 obscureText: hidePassword,
//               ),

//               const SizedBox(height: 24),
//               // Save Button with Gradient (consider using a separate theme file)
//               ElevatedButton(
//                 onPressed: _saveCredentials,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple[400],
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                 ),
//                 child: const Text('Save Credentials'),
//               ),
//               const SizedBox(height: 4),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20),
//                 child: Text(
//                   'Your credentials are stored securely on this device only '
//                   'and are not sent to any servers.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.purple[300],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Card(
//                 elevation: 4,
//                 shadowColor: Colors.purple,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'How to get a Gmail App Password:',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         '1. Go to your Google Account settings:\n'
//                         '2. Navigate to Security.\n'
//                         '3. Enable 2-Step Verification if it\'s not already on.\n'
//                         '4. Look for "App passwords" and click on it.\n'
//                         '5. Give App Name as of your choice e.g. "My App".\n'
//                         '6. Google will generate a 16-character app password. Copy it and paste it here in password field.',
//                       ),
//                       const SizedBox(height: 8),
//                       TextButton(
//                         onPressed: () async {
//                           const url =
//                               'https://myaccount.google.com/apppasswords';
//                           try {
//                             await launchUrlString(url);
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content: Text('Could not launch URL.')),
//                             );
//                           }
//                         },
//                         child: Row(
//                           children: const [
//                             Icon(Icons.link, size: 16), // Link icon
//                             SizedBox(width: 4),
//                             Text('Go to App Passwords (Opens in Browser)'),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               FadeTransition(
//                 opacity: _animation,
//                 child: const Padding(
//                   padding: EdgeInsets.only(top: 16.0),
//                   child: Text(
//                     'Credentials saved successfully!',
//                     style: TextStyle(color: Colors.green),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // To Send Email Throgh GoogleAPIs

// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_sign_in/google_sign_in.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:url_launcher/url_launcher_string.dart';
// // import './../utils/input_decorations.dart';

// // class SettingsScreen extends StatefulWidget {
// //   const SettingsScreen({super.key});

// //   @override
// //   State<SettingsScreen> createState() => _SettingsScreenState();
// // }

// // class _SettingsScreenState extends State<SettingsScreen>
// //     with SingleTickerProviderStateMixin {
// //   final _emailController = TextEditingController();
// //   final _prefs = SharedPreferences.getInstance();
// //   late AnimationController _animationController;
// //   late Animation<double> _animation;
// //   bool hidePassword = true;
// //   final GoogleSignIn _googleSignIn = GoogleSignIn(
// //       scopes: ['email', 'https://www.googleapis.com/auth/gmail.send']);

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadCredentials();
// //     _animationController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 300),
// //     );
// //     _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
// //       parent: _animationController,
// //       curve: Curves.easeOut,
// //     ));
// //   }

// //   @override
// //   void dispose() {
// //     _animationController.dispose();
// //     _emailController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _loadCredentials() async {
// //     final prefs = await _prefs;
// //     setState(() {
// //       _emailController.text = prefs.getString('email') ?? '';
// //     });
// //   }

// //   Future<void> _signInWithGoogle() async {
// //     try {
// //       GoogleSignInAccount? account = await _googleSignIn.signIn();
// //       if (account != null) {
// //         // Await authentication to get the tokens
// //         final authentication = await account.authentication;
// //         final prefs = await _prefs;
// //         await prefs.setString('email', account.email);
// //         await prefs.setString('accessToken', authentication.accessToken ?? '');
// //         await prefs.setString('idToken', authentication.idToken ?? '');
// //         _animationController.reset();
// //         _animationController.forward();
// //       }
// //     } catch (e) {
// //       print('Error signing in: $e');
// //     }
// //   }

// //   Future<void> _saveCredentials() async {
// //     // Store credentials in SharedPreferences (already done after Google Sign-In)
// //     _animationController.reset();
// //     _animationController.forward();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Settings'),
// //         centerTitle: true,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               TextField(
// //                 controller: _emailController,
// //                 decoration: buildInputDecoration(
// //                   labelText: 'Gmail Address',
// //                   prefixIcon: CupertinoIcons.cloud_upload,
// //                 ),
// //                 keyboardType: TextInputType.emailAddress,
// //               ),
// //               const SizedBox(height: 24),
// //               ElevatedButton(
// //                 onPressed: _signInWithGoogle,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.deepPurple[400],
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(8.0),
// //                   ),
// //                 ),
// //                 child: const Text('Sign in with Google'),
// //               ),
// //               const SizedBox(height: 16),
// //               FadeTransition(
// //                 opacity: _animation,
// //                 child: const Padding(
// //                   padding: EdgeInsets.only(top: 16.0),
// //                   child: Text(
// //                     'Credentials saved successfully!',
// //                     style: TextStyle(color: Colors.green),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './../utils/input_decorations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _prefs = SharedPreferences.getInstance();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool hidePassword = true;
  bool isOAuthMode = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://mail.google.com/',
    ],
  );

  @override
  void initState() {
    super.initState();
    _loadCredentials();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadCredentials() async {
    final prefs = await _prefs;
    setState(() {
      isOAuthMode = prefs.getBool('isOAuthMode') ?? false;
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
    });
  }

  Future<void> _saveCredentials() async {
    try {
      final prefs = await _prefs;
      await prefs.setBool('isOAuthMode', isOAuthMode);

      if (!isOAuthMode) {
        await prefs.setString('email', _emailController.text);
        await prefs.setString('password', _passwordController.text);
      }

      _animationController.reset();
      _animationController.forward();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Settings saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        setState(() {
          _emailController.text = account.email;
        });
        _saveCredentials();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign In failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildAuthModeSelector() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Authentication Method:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            CupertinoSlidingSegmentedControl<bool>(
              groupValue: isOAuthMode,
              children: const {
                false: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('SMTP'),
                ),
                true: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OAuth'),
                ),
              },
              onValueChanged: (value) {
                if (value != null) {
                  setState(() {
                    isOAuthMode = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOAuthSection() {
    return Column(
      children: [
        const Icon(
          Icons.security,
          size: 48,
          color: Colors.deepPurple,
        ),
        const SizedBox(height: 16),
        const Text(
          'Sign in with Google',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Secure authentication using your Google Account',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _handleGoogleSignIn,
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple[400],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSMTPSection() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: buildInputDecoration(
            labelText: 'Gmail Address',
            prefixIcon: CupertinoIcons.mail,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: buildInputDecoration(
            labelText: 'App Password',
            helperText: 'Use Gmail App Password, not your account password',
            prefixIcon: CupertinoIcons.lock,
            suffixIcon: IconButton(
              icon: Icon(
                hidePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  hidePassword = !hidePassword;
                });
              },
            ),
          ),
          obscureText: hidePassword,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _saveCredentials,
          icon: const Icon(Icons.save),
          label: const Text('Save Credentials'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple[400],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.settings),
            SizedBox(width: 8),
            Text('Settings'),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAuthModeSelector(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isOAuthMode ? _buildOAuthSection() : _buildSMTPSection(),
            ),
            const SizedBox(height: 24),
            if (!isOAuthMode) ...[
              Card(
                elevation: 4,
                shadowColor: Colors.purple.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.info_outline, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(
                            'How to get a Gmail App Password:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Go to your Google Account settings\n'
                        '2. Navigate to Security\n'
                        '3. Enable 2-Step Verification if not already on\n'
                        '4. Look for "App passwords" and click on it\n'
                        '5. Give App Name as of your choice\n'
                        '6. Copy the generated 16-character password',
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () async {
                          const url =
                              'https://myaccount.google.com/apppasswords';
                          try {
                            await launchUrlString(url);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not launch URL.'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Go to App Passwords'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
