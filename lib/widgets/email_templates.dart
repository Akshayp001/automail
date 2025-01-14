// lib/widgets/email_templates.dart
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/email_template.dart';
import '../services/template_service.dart';
import '../services/email_service.dart';
import '../screens/email_compose_screen.dart';

class EmailTemplates extends StatefulWidget {
  const EmailTemplates({super.key});

  @override
  State<EmailTemplates> createState() => _EmailTemplatesState();
}

class _EmailTemplatesState extends State<EmailTemplates> {
  final TemplateService _templateService =
      TemplateService(userId: FirebaseAuth.instance.currentUser?.email ?? '');
  final EmailService _emailService = EmailService();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  Future<void> _showSendDialog(EmailTemplate template) async {
    final recipientsController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Send Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Template: ${template.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: recipientsController,
                decoration: InputDecoration(
                  labelText: 'To (comma-separated)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Subject: ${template.subject}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Send'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (recipientsController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter at least one recipient'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                _sendTemplateEmail(template, recipientsController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendTemplateEmail(
      EmailTemplate template, String recipients) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      await _emailService.sendEmail(
        to: recipients,
        subject: template.subject,
        body: template.body,
        attachments: template.attachmentPaths.map((path) {
          final fileName = path.split('/').last;
          return PlatformFile(
            name: fileName,
            size: 0,
            path: path,
          );
        }).toList(),
      );

      Get.back(); // Close loading dialog

      Get.snackbar(
        'Success',
        'Email sent successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.back(); // Close loading dialog

      Get.snackbar(
        'Error',
        'Failed to send email: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildTemplateCard(EmailTemplate template) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              Colors.purple[50]!,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'use',
                        child: Row(
                          children: [
                            Icon(Icons.edit_document),
                            SizedBox(width: 8),
                            Text('Use Template'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'send',
                        child: Row(
                          children: [
                            Icon(Icons.send),
                            SizedBox(width: 8),
                            Text('Use and Send'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'use':
                          Get.to(() => EmailComposerScreen(template: template));
                          break;
                        case 'send':
                          _showSendDialog(template);
                          break;
                        case 'edit':
                          // Implement edit functionality

                          break;
                        case 'delete':
                          TemplateService(
                                  userId: FirebaseAuth
                                          .instance.currentUser?.email ??
                                      '')
                              .deleteTemplate(template.id);
                          setState(() {});
                          break;
                      }
                    },
                  ),
                ],
              ),
            ),
            // Rest of the card content remains the same
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.subject,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Text(
                  //   template.body,
                  //   style: TextStyle(
                  //     color: Colors.grey[600],
                  //     fontSize: 14,
                  //   ),
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                  // const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.folder, size: 16, color: Colors.purple[300]),
                      const SizedBox(width: 4),
                      Text(
                        template.category,
                        style: TextStyle(
                          color: Colors.purple[300],
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (template.attachmentPaths.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.attach_file,
                                size: 20, color: Colors.amber.shade600),
                            const SizedBox(width: 4),
                            Text(
                              '${template.attachmentPaths.length}',
                              style: TextStyle(
                                color: Colors.amber.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: template.tags
                        .map((tag) => Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.purple[50],
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search templates...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.purple[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.purple[200]!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      ['All', 'Work', 'Personal', 'Other'].map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(category),
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                        },
                        selectedColor: Colors.purple[100],
                        checkmarkColor: Colors.purple[700],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<EmailTemplate>>(
            future: _templateService.getAllTemplates(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_outlined,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No templates found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              var templates = snapshot.data!;
              if (_selectedCategory != 'All') {
                templates = templates
                    .where((t) => t.category == _selectedCategory)
                    .toList();
              }
              if (_searchQuery.isNotEmpty) {
                templates = templates
                    .where((t) =>
                        t.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        t.subject
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        t.body
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                    .toList();
              }

              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: templates.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _buildTemplateCard(templates[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
