import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/email_template.dart';
import '../services/email_service.dart';
import '../services/template_service.dart';

class EmailComposer extends StatefulWidget {
  const EmailComposer({super.key});

  @override
  State<EmailComposer> createState() => _EmailComposerState();
}

class _EmailComposerState extends State<EmailComposer> {
  final _toController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  List<PlatformFile> _attachments = [];

  late EmailTemplate _selectedTemplate;

  // Function to split comma-separated email addresses
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
          const SnackBar(content: Text('Email sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending email: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<EmailTemplate>>(
          future: TemplateService().getAllTemplates(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final templates = snapshot.data!;
              return Column(
                children: [
                  TextField(
                    controller: _toController,
                    decoration: const InputDecoration(
                      labelText: 'To (comma-separated)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField(
                    value: _selectedTemplate,
                    items: templates
                        .map((template) => DropdownMenuItem(
                              value: template,
                              child: Text(template.name),
                            ))
                        .toList(),
                    onChanged: (EmailTemplate? newTemplate) {
                      setState(() {
                        _selectedTemplate = newTemplate!;
                        if (newTemplate != null) {
                          _toController.text = newTemplate.subject;
                          _subjectController.text = newTemplate.subject;
                          _bodyController.text = newTemplate.body;
                        }
                      });
                    },
                    hint: const Text('Select Template (Optional)'),
                  ),
                 
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: null,
                      expands: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Add Attachments'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _sendEmail,
                        child: const Text('Send Email'),
                      ),
                    ],
                  ),
                  if (_attachments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        children: _attachments
                            .map((file) => Chip(
                                  label: Text(file.name),
                                  onDeleted: () {
                                    setState(() {
                                      _attachments.remove(file);
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                ],
              );
            }
            return Container();
          }),
    );
  }
}
