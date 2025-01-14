// lib/services/email_service.dart
import 'dart:io';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class EmailService {
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
    List<PlatformFile>? attachments,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');

    if (email == null || password == null) {
      throw Exception('Email credentials not found. Please check settings.');
    }

    final smtpServer = gmail(email, password);
  

    final message = Message()
      ..from = Address(email)
      ..recipients.addAll(to.split(',').toList())
      ..subject = subject
      ..text = body;

    if (attachments != null) {
      for (var file in attachments) {
        message.attachments.add(
          FileAttachment(File(file.path!))
            ..location = Location.attachment
            ..cid = '<${file.name}>',
        );
      }
    }

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Error sending email: $e');
      rethrow;
    }
  }
}
