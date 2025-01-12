import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/email_service.dart';

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
      await EmailService().sendEmail(
        to: _toController.text,
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
      child: Column(
        children: [
          TextField(
            controller: _toController,
            decoration: const InputDecoration(
              labelText: 'To',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
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
      ),
    );
  }
}