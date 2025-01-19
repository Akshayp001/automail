import 'package:automail/services/email_service.dart';
import 'package:automail/widgets/drawer_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/app_version_service.dart';
import '../../widgets/email_templates.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppVersionService.checkForUpdates();
    EmailService.checkAndShowEmailSetupDialog();
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text('AutoMail'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ElevatedButton.icon(
              //   icon: const Icon(Icons.explore),
              //   label: const Text('Explore Templates'),
              //   style: ElevatedButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 32,
              //       vertical: 16,
              //     ),
              //   ),
              //   // onPressed: () => _showTemplateExplorer(context),
              //   onPressed: () {
              //     Get.snackbar('Comming Soon..', 'Feature Comming Soon..',
              //         icon: Icon(CupertinoIcons.timer),
              //         backgroundColor: Colors.amber.shade200);
              //   },
              // ),
              // const SizedBox(height: 16),
              // const Text(
              //   'or',
              //   style: TextStyle(
              //     fontSize: 16,
              //     color: Colors.grey,
              //   ),
              // ),
              // const SizedBox(height: 16),
              // const Text(
              //   'Create a new email using the + button below',
              //   style: TextStyle(
              //     fontSize: 16,
              //     color: Colors.grey,
              //   ),
              // ),
              Expanded(child: EmailTemplates())
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Get.theme.primaryColor,
        onPressed: () => Get.toNamed('/compose'),
        // child: const Icon(Icons.add),
        label: Row(
          children: [
            Icon(CupertinoIcons.pen),
            SizedBox(
              width: 4,
            ),
            Text('Compose Email')
          ],
        ),
      ),
    );
  }
}
