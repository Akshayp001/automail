import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/email_composer_controller.dart';
import '../models/email_template.dart';
import 'package:file_picker/file_picker.dart';

class EmailComposerScreen extends StatelessWidget {
  const EmailComposerScreen({super.key});

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    bool expands = false,
    int? maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        expands: expands,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: label,
          // labelText: label,
          label: Container(
              decoration: BoxDecoration(
                  color: Colors.amber.shade200,
                  borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                label,
                style: TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold),
              )),
          // labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.purple[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.purple[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.purple[400]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildAttachmentList(EmailComposerController controller) {
    return Obx(() {
      if (controller.attachments.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Attachments (${controller.attachments.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.attachments.length,
              itemBuilder: (context, index) {
                final file = controller.attachments[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _getFileIcon(file.extension ?? ''),
                      color: Colors.purple[700],
                    ),
                    title: Text(
                      file.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      file.size == 0 ? 'Unknown' : _formatFileSize(file.size),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => controller.removeAttachment(file),
                      color: Colors.red[400],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmailComposerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose Email'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: 20,
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700),
              label: Text('Save'),
              icon: const Icon(Icons.save_outlined),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Save as Template'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildTextField(
                          controller: controller.templateNameController,
                          label: 'Template Name',
                        ),
                        const SizedBox(height: 16),
                        buildTextField(
                          controller: controller.categoryController,
                          label: 'Category',
                        ),
                        const SizedBox(height: 16),
                        buildTextField(
                          controller: controller.tagsController,
                          label: 'Tags (comma-separated)',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.purple[700]),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          controller.saveAsTemplate();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[700],
                        ),
                        label: const Text('Save'),
                        icon: Icon(CupertinoIcons.floppy_disk),
                      ),
                    ],
                  ),
                );
              },
              // tooltip: 'Save as Template',
            ),
          ),
        ],
      ),
      body: Container(
        height: Get.height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple[700]!,
              Colors.purple[50]!,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTextField(controller: controller.toController, label: 'To'),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Obx(
                  () => DropdownButtonFormField<EmailTemplate>(
                    value: controller.selectedTemplate.value,
                    items: [
                      ...controller.mySavedTemplatesList.map(
                        (template) => DropdownMenuItem<EmailTemplate>(
                          value: template,
                          child: Text(template.name),
                        ),
                      )
                    ],
                    onChanged: (newTemplate) {
                      if (newTemplate != null) {
                        controller.selectedTemplate.value = newTemplate;
                        controller.subjectController.text = newTemplate.subject;
                        controller.bodyController.text = newTemplate.body;
                        controller.attachments.value = newTemplate
                            .attachmentPaths
                            .map((val) => PlatformFile(
                                name: val.split('/').last, size: 0, path: val))
                            .toList();
                      }
                    },
                    decoration: InputDecoration(
                      // labelText: 'Template',l
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      label: Container(
                          decoration: BoxDecoration(
                              color: Colors.amber.shade200,
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Text(
                            'Template',
                            style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          )),
                      // labelStyle: TextStyle(color: Colors.purple[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.purple[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.purple[400]!, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: controller.subjectController,
                label: 'Subject',
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: controller.bodyController,
                label: 'Body',
                maxLines: 10,
              ),
              buildAttachmentList(controller),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: controller.pickFiles,
                    icon: Icon(Icons.attach_file, color: Colors.purple[700]),
                    label: Text(
                      'Add Attachments',
                      style: TextStyle(color: Colors.purple[700]),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: controller.sendEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text('Send'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
