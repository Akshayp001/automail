import 'package:flutter/material.dart';
import '../../widgets/email_composer.dart';
import '../../widgets/email_templates.dart';
import '../../screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email App'),
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
      body: Column(
        children: [
          const EmailTemplates(),
           Expanded(child: EmailComposer()),
        ],
      ),
    );
  }
}
