import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../services/email_service.dart';
import '../services/template_service.dart';
import '../models/email_template.dart';

class EmailComposerScreen extends StatefulWidget {
  final EmailTemplate? template;
  final String? initialEmail; // Optional initial email address

  const EmailComposerScreen({super.key, this.template, this.initialEmail});

  @override
  State<EmailComposerScreen> createState() => _EmailComposerScreenState();
}

class _EmailComposerScreenState extends State<EmailComposerScreen> {
  final _toController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  final _templateNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();
  // final _extra1Controller = TextEditingController();
  // final _extra2Controller = TextEditingController();
  List<PlatformFile> _attachments = [];
  // final _templateService = TemplateService();
  EmailTemplate? _selectedTemplate;

  List<String> _parseRecipients(String recipientString) {
    return recipientString.split(',').map((e) => e.trim()).toList();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _attachments = result.files;
      });
    }
  }

  Future<void> _saveAsTemplate() async {
    // Get the paths from PlatformFile objects
    final attachmentPaths = _attachments
        .map((file) => file.path!)
        .where((path) => path.isNotEmpty)
        .toList();

    final template = EmailTemplate(
      id: const Uuid().v4(),
      name: _templateNameController.text,
      subject: _subjectController.text,
      body: _bodyController.text,
      attachmentPaths: attachmentPaths,
      tags: _tagsController.text.split(',').map((e) => e.trim()).toList(),
      category: _categoryController.text,
      // extra1: _extra1Controller.text,
      // extra2: _extra2Controller.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await TemplateService(
            userId: FirebaseAuth.instance.currentUser?.email ?? '')
        .saveTemplate(template);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Template saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showSaveTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save as Template'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _templateNameController,
                decoration: const InputDecoration(
                  labelText: 'Template Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              // const SizedBox(height: 16),
              // TextField(
              //   controller: _extra1Controller,
              //   decoration: const InputDecoration(
              //     labelText: 'Extra Field 1',
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              // const SizedBox(height: 16),
              // TextField(
              //   controller: _extra2Controller,
              //   decoration: const InputDecoration(
              //     labelText: 'Extra Field 2',
              //     border: OutlineInputBorder(),
              //   ),
              // ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveAsTemplate();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail() async {
    try {
      final recipients = _parseRecipients(_toController.text);
      await EmailService().sendEmail(
        to: recipients.join(','),
        subject: _subjectController.text,
        body: _bodyController.text,
        attachments: _attachments,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTextField({
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
          labelText: label,
          labelStyle: TextStyle(color: Colors.purple[700]),
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
            borderSide: BorderSide(color: Colors.purple[400]!),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  void initState() {
    if (widget.initialEmail != null) {
      _toController.text = widget.initialEmail!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compose Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined, color: Colors.white),
            onPressed: _showSaveTemplateDialog,
            tooltip: 'Save as Template',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple[100]!,
              Colors.purple[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // // Custom App Bar
              // Container(
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       colors: [Colors.purple[700]!, Colors.purple[500]!],
              //     ),
              //   ),
              //   child: Row(
              //     children: [
              //       IconButton(
              //         icon: const Icon(Icons.arrow_back, color: Colors.white),
              //         onPressed: () => Navigator.pop(context),
              //       ),
              //       const Text(
              //         'Compose Email',
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 20,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       const Spacer(),
              //       IconButton(
              //         icon:
              //             const Icon(Icons.save_outlined, color: Colors.white),
              //         onPressed: _showSaveTemplateDialog,
              //         tooltip: 'Save as Template',
              //       ),
              //     ],
              //   ),
              // ),

              // Email Composer Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildTextField(
                      controller: _toController,
                      label: 'To (comma-separated)',
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<EmailTemplate>>(
                      future: TemplateService(
                              userId:
                                  FirebaseAuth.instance.currentUser?.email ??
                                      '')
                          .getAllTemplates(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final templates = snapshot.data!;

                          // Ensure the _selectedTemplate is part of the templates list
                          if (_selectedTemplate != null &&
                              !templates.contains(_selectedTemplate)) {
                            _selectedTemplate =
                                null; // Reset if it doesn't match
                          }

                          return DropdownButtonFormField<EmailTemplate>(
                            value: _selectedTemplate,
                            items: templates.map((template) {
                              return DropdownMenuItem<EmailTemplate>(
                                value: template,
                                child: Text(template.name),
                              );
                            }).toList(),
                            onChanged: (EmailTemplate? newTemplate) {
                              setState(() {
                                _selectedTemplate = newTemplate;

                                if (newTemplate != null) {
                                  _subjectController.text = newTemplate.subject;
                                  _bodyController.text = newTemplate.body;
                                  _attachments = newTemplate.attachmentPaths
                                      .map((path) => PlatformFile(
                                          name: path.split('/').last,
                                          size: 0,
                                          path: path))
                                      .toList();
                                }
                              });
                            },
                            hint: const Text('Select Template (Optional)'),
                          );
                        } else if (snapshot.hasError) {
                          return SizedBox.shrink();
                        }
                        return Center(child: const CircularProgressIndicator());
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _subjectController,
                      label: 'Subject',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bodyController,
                      label: 'Message',
                      maxLines: 15,
                    ),
                    const SizedBox(height: 16),
                    if (_attachments.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple[200]!),
                        ),
                        child: Wrap(
                          spacing: 8.0,
                          children: _attachments
                              .map((file) => Chip(
                                    label: Text(file.name),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 18),
                                    onDeleted: () {
                                      setState(() {
                                        _attachments.remove(file);
                                      });
                                    },
                                    backgroundColor: Colors.purple[50],
                                    labelStyle:
                                        TextStyle(color: Colors.purple[700]),
                                  ))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _pickFiles,
                          icon: Icon(Icons.attach_file,
                              color: Colors.purple[700]),
                          label: Text(
                            'Add Attachments',
                            style: TextStyle(color: Colors.purple[700]),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.purple[50],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _sendEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Send Email'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
