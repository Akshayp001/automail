import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'email_compose_screen.dart';
import '../../widgets/email_templates.dart';
import '../../screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // void _showTemplateExplorer(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Email Templates'),
  //         content: SizedBox(
  //           width: MediaQuery.of(context).size.width * 0.9,
  //           height: MediaQuery.of(context).size.height * 0.8,
  //           child: const EmailTemplates(),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Close'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoMail'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.explore),
                label: const Text('Explore Templates'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),

                // onPressed: () => _showTemplateExplorer(context),
                onPressed: () {
                  Get.snackbar('Comming Soon..', 'Feature Comming Soon..',
                      icon: Icon(CupertinoIcons.timer),
                      backgroundColor: Colors.amber.shade200);
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'or',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create a new email using the + button below',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Expanded(child: EmailTemplates())
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(EmailComposerScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
