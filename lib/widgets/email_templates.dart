import 'package:flutter/material.dart';

class EmailTemplates extends StatelessWidget {
  const EmailTemplates({super.key});

  final List<Map<String, String>> _templates = const [
    {
      'name': 'Meeting Request',
      'subject': 'Meeting Request: [Topic]',
      'body':
          'Dear [Name],\n\nI hope this email finds you well. I would like to schedule a meeting to discuss [topic].\n\nBest regards,\n[Your Name]',
    },
    {
      'name': 'Thank You',
      'subject': 'Thank You',
      'body':
          'Dear [Name],\n\nThank you for [reason]. I really appreciate your time and effort.\n\nBest regards,\n[Your Name]',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _templates.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement template selection
              },
              child: Text(_templates[index]['name']!),
            ),
          );
        },
      ),
    );
  }
}
