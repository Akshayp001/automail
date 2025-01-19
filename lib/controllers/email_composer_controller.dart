import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../services/email_service.dart';
import '../services/template_service.dart';
import '../models/email_template.dart';

class EmailComposerController extends GetxController {
  final toController = TextEditingController();
  final subjectController = TextEditingController();
  final bodyController = TextEditingController();
  final templateNameController = TextEditingController();
  final categoryController = TextEditingController();
  final tagsController = TextEditingController();

  var attachments = <PlatformFile>[].obs;
  Rx<EmailTemplate?> selectedTemplate = Rx<EmailTemplate?>(null);
  late final TemplateService templateService;
  RxList<EmailTemplate> mySavedTemplatesList = <EmailTemplate>[].obs;

  @override
  void onInit() {
    super.onInit();
    templateService =
        TemplateService(userId: FirebaseAuth.instance.currentUser?.email ?? '');
    initInitials();
    final initialEmail = Get.arguments?['initialEmail'] as String?;

    if (initialEmail != null) {
      toController.text = initialEmail;
    }
  }

  initInitials() async {
    await fetchTemplates();
    final initialTemplate =
        Get.arguments?['initialTemplate'] as Map<String, dynamic>?;
    print(initialTemplate);
    print(initialTemplate.runtimeType);

    if (initialTemplate != null) {
      final initTemp = EmailTemplate.fromJson(initialTemplate);
      subjectController.text = initTemp.subject;
      bodyController.text = initTemp.body;
      attachments.value = initTemp.attachmentPaths
          .map((val) =>
              PlatformFile(name: val.split('/').last, size: 0, path: val))
          .toList();
      // selectedTemplate.value = initTemp;
    }
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      attachments.addAll(result.files);
    }
  }

  void removeAttachment(PlatformFile file) {
    attachments.remove(file);
  }

  Future<void> saveAsTemplate() async {
    final attachmentPaths = attachments
        .map((file) => file.path!)
        .where((path) => path.isNotEmpty)
        .toList();
    final template = EmailTemplate(
      id: const Uuid().v4(),
      name: templateNameController.text,
      subject: subjectController.text,
      body: bodyController.text,
      attachmentPaths: attachmentPaths,
      tags: tagsController.text.split(',').map((e) => e.trim()).toList(),
      category: categoryController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await templateService.saveTemplate(template);
    Get.back();
    Get.snackbar(
      'Success',
      'Template saved successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> sendEmail() async {
    try {
      final recipients =
          toController.text.split(',').map((e) => e.trim()).toList();
      await EmailService().sendEmail(
        to: recipients.join(','),
        subject: subjectController.text,
        body: bodyController.text,
        attachments: attachments,
      );
      Get.snackbar('Success', 'Email sent successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send email: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> fetchTemplates() async {
    mySavedTemplatesList.value = await templateService.getAllTemplates();
  }
}
